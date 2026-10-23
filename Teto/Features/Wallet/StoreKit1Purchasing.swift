import Foundation
import StoreKit

/// StoreKit 1 purchases for the diamond packages. A transaction is finished only after its diamonds are saved.
@MainActor
final class StoreKit1Purchasing: NSObject, SKPaymentTransactionObserver {
    var onChange: ((WalletLedger, [String: String]) -> Void)?

    private let productsFetcher = TetoStoreProductFetcher.shared
    private var ledger = WalletLedger.empty
    private var products: [String: SKProduct] = [:]
    private var prices: [String: String] = [:]
    private var productWaiters: [CheckedContinuation<Void, Never>] = []
    private var productRequestInFlight = false
    private var productRequestGeneration = 0
    private var persist: ((WalletLedger) async -> Bool)?
    private var observing = false
    private var acceptingPurchases = false
    private var queueDelivered = false
    private var expected: [String: Int] = [:]
    private var waiters: [String: [PurchaseWait]] = [:]
    private var preexistingObjects: Set<ObjectIdentifier> = []
    private var preexistingIDs: Set<String> = []
    private var finishedObjects: Set<ObjectIdentifier> = []
    private var tail: Task<Void, Never>?

    override init() {
        super.init()
        productsFetcher.onFinish = { [weak self] loaded, invalid in
            Task { @MainActor in
                self?.apply(loaded, invalid: invalid)
            }
        }
        productsFetcher.onFail = { [weak self] in
            Task { @MainActor in
                self?.failProductRequest()
            }
        }
    }

    func adopt(_ ledger: WalletLedger) {
        self.ledger = ledger
        publish()
    }

    func setPersist(_ persist: @escaping (WalletLedger) async -> Bool) {
        self.persist = persist
    }

    func start() async {
        guard persist != nil else { return }
        guard !observing else {
            acceptingPurchases = true
            reloadProductsIfNeeded()
            return
        }
        queueDelivered = false
        for transaction in SKPaymentQueue.default().transactions {
            rememberPreexisting(transaction)
        }
        observing = true
        acceptingPurchases = false
        SKPaymentQueue.default().add(self)
        for _ in 0..<10 { await Task.yield() }
        await drain()
        acceptingPurchases = true
        beginProductRequest()
    }

    func reloadProductsIfNeeded() {
        guard acceptingPurchases, products.isEmpty else { return }
        beginProductRequest()
    }

    func stop() async {
        acceptingPurchases = false
        if observing {
            SKPaymentQueue.default().remove(self)
            observing = false
        }
        await drain()
    }

    func clearMemory() {
        ledger = .empty
        let pending = waiters
        waiters = [:]
        expected = [:]
        let message = "Purchase did not go through. You have not been charged."
        for list in pending.values {
            for wait in list { settle(wait, message: message) }
        }
        publish()
    }

    /// Spends diamonds for a gift on this device. Returns an English message when nothing was spent.
    func spend(_ gift: DanceGift, quantity: Int) async -> String? {
        guard (1...99).contains(quantity), gift.diamonds > 0 else {
            return "Please check the quantity and try again."
        }
        let (cost, overflow) = gift.diamonds.multipliedReportingOverflow(by: quantity)
        guard !overflow, cost > 0 else { return "Please check the quantity and try again." }
        guard ledger.diamonds >= cost else { return "Not enough diamonds. No diamonds were spent." }
        var next = ledger
        next.diamonds -= cost
        let countText = quantity.formatted(.number.locale(Locale(identifier: "en_US")))
        let costText = cost.formatted(.number.locale(Locale(identifier: "en_US")))
        next.activity.insert(
            WalletActivity(
                id: UUID().uuidString,
                title: "Sent \(countText) × \(gift.name) · \(costText) diamonds",
                currency: .diamonds, amount: cost, date: Date(), kind: "gift"
            ),
            at: 0
        )
        if next.activity.count > 40 { next.activity = Array(next.activity.prefix(40)) }
        guard next.isValid, let persist, await persist(next) else {
            return "Gift not sent. No diamonds were spent."
        }
        ledger = next
        publish()
        return nil
    }

    func purchase(_ package: WalletPackage) async -> String? {
        guard acceptingPurchases else { return "Please wait for the current request to finish." }
        guard SKPaymentQueue.canMakePayments() else {
            return "Purchases are turned off in Settings. You have not been charged."
        }
        guard let product = await resolveProduct(package.storeProductID) else {
            return "This package is not available. You have not been charged."
        }
        let wait = PurchaseWait()
        expected[package.storeProductID, default: 0] += 1
        waiters[package.storeProductID, default: []].append(wait)
        SKPaymentQueue.default().add(SKPayment(product: product))
        return await withCheckedContinuation { continuation in
            if wait.settled {
                continuation.resume(returning: wait.message)
            } else {
                wait.continuation = continuation
            }
        }
    }

    private func resolveProduct(_ productID: String) async -> SKProduct? {
        if let product = products[productID] { return product }
        if !productRequestInFlight { beginProductRequest() }
        if productRequestInFlight {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                productWaiters.append(continuation)
            }
        }
        return products[productID]
    }

    /// Asks StoreKit 1 for the catalog IDs. A second call waits on the request already running.
    private func beginProductRequest() {
        guard !productRequestInFlight else { return }
        productRequestInFlight = true
        productRequestGeneration += 1
        let generation = productRequestGeneration
        productsFetcher.start(WalletCatalog.productIDs)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 20_000_000_000)
            guard self.productRequestGeneration == generation, self.productRequestInFlight else { return }
            self.productRequestInFlight = false
            self.resumeProductWaiters()
        }
    }

    private func apply(_ loaded: [SKProduct], invalid: [String]) {
        let rejected = Set(invalid)
        var nextProducts: [String: SKProduct] = [:]
        var nextPrices: [String: String] = [:]
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        for product in loaded {
            guard !rejected.contains(product.productIdentifier),
                  WalletCatalog.package(forProductID: product.productIdentifier) != nil else { continue }
            formatter.locale = product.priceLocale
            nextProducts[product.productIdentifier] = product
            nextPrices[product.productIdentifier] = formatter.string(from: product.price) ?? "See price"
        }
        products = nextProducts
        prices = nextPrices
        productRequestInFlight = false
        publish()
        resumeProductWaiters()
    }

    private func failProductRequest() {
        productRequestInFlight = false
        resumeProductWaiters()
    }

    private func resumeProductWaiters() {
        let waiters = productWaiters
        productWaiters.removeAll()
        for waiter in waiters { waiter.resume() }
    }

    private func publish() {
        onChange?(ledger, prices)
    }

    private func enqueue(_ transactions: [SKPaymentTransaction]) {
        let previous = tail
        let next = Task { @MainActor in
            await previous?.value
            for transaction in transactions {
                await self.handle(transaction)
            }
        }
        tail = next
    }

    private func handle(_ transaction: SKPaymentTransaction) async {
        if finishedObjects.contains(ObjectIdentifier(transaction)) { return }
        let productID = transaction.payment.productIdentifier
        switch transaction.transactionState {
        case .purchasing:
            return
        case .deferred:
            rememberPreexisting(transaction)
            resumeWaiting(
                productID,
                message: "This purchase is waiting for approval. Diamonds are added when it is approved."
            )
        case .failed:
            finish(transaction)
            resumeWaiting(productID, message: failureMessage(transaction.error))
        case .purchased, .restored:
            guard WalletCatalog.package(forProductID: productID) != nil else {
                resumeWaiting(productID, message: "This package is not available. You have not been charged.")
                return
            }
            switch await credit(transaction) {
            case .savedNew:
                finish(transaction)
                resumeWaiting(productID, message: nil)
            case .alreadySaved:
                finish(transaction)
                resumeWaiting(productID, message: nil)
            case .notSaved:
                rememberPreexisting(transaction)
                resumeWaiting(
                    productID,
                    message: "Diamonds could not be saved on this device. If you were charged, they will be added when you open the app again."
                )
            }
        default:
            return
        }
    }

    private func drain() async {
        var drained: Task<Void, Never>?
        while let next = tail, next != drained {
            drained = next
            await next.value
        }
    }

    /// Credits one catalog consumable at most once.
    private func credit(_ transaction: SKPaymentTransaction) async -> CreditOutcome {
        let productID = transaction.payment.productIdentifier
        guard let package = WalletCatalog.package(forProductID: productID) else { return .notSaved }
        let identifiers = transactionIdentifiers(transaction)
        guard !identifiers.isEmpty else { return .notSaved }
        if identifiers.contains(where: { ledger.creditedTransactionIDs.contains($0) }) {
            preexistingIDs.formUnion(identifiers)
            guard let persist, await persist(ledger) else { return .notSaved }
            return .alreadySaved
        }
        let quantity = transaction.payment.quantity
        let (total, overflow) = package.amount.multipliedReportingOverflow(by: quantity)
        let (balance, balanceOverflow) = ledger.diamonds.addingReportingOverflow(total)
        guard quantity > 0, package.amount > 0, !overflow, !balanceOverflow, balance >= ledger.diamonds else {
            return .notSaved
        }
        var next = ledger
        next.diamonds = balance
        let amountText = total.formatted(.number.locale(Locale(identifier: "en_US")))
        next.activity.insert(
            WalletActivity(
                id: identifiers[0], title: "Added \(amountText) diamonds",
                currency: .diamonds, amount: total, date: transaction.transactionDate ?? Date()
            ),
            at: 0
        )
        if next.activity.count > 40 { next.activity = Array(next.activity.prefix(40)) }
        for identifier in identifiers where !next.creditedTransactionIDs.contains(identifier) {
            next.creditedTransactionIDs.append(identifier)
        }
        guard next.isValid, let persist, await persist(next) else { return .notSaved }
        preexistingIDs.formUnion(identifiers)
        ledger = next
        publish()
        return .savedNew
    }

    private func finish(_ transaction: SKPaymentTransaction) {
        finishedObjects.insert(ObjectIdentifier(transaction))
        forgetPreexisting(transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func resumeWaiting(_ productID: String, message: String?) {
        guard let count = expected[productID], count > 0 else { return }
        expected[productID] = count == 1 ? nil : count - 1
        guard var queue = waiters[productID], !queue.isEmpty else { return }
        let wait = queue.removeFirst()
        waiters[productID] = queue
        settle(wait, message: message)
    }

    private func settle(_ wait: PurchaseWait, message: String?) {
        guard !wait.settled else { return }
        wait.settled = true
        wait.message = message
        if let continuation = wait.continuation {
            wait.continuation = nil
            continuation.resume(returning: message)
        }
    }

    private func failureMessage(_ error: Error?) -> String {
        guard let error = error as? SKError else {
            return "Purchase did not go through. You have not been charged."
        }
        switch error.code {
        case .paymentCancelled:
            return "Purchase canceled. You have not been charged."
        case .paymentNotAllowed:
            return "Purchases are turned off in Settings. You have not been charged."
        case .storeProductNotAvailable:
            return "This package is not available. You have not been charged."
        default:
            return "Purchase did not go through. You have not been charged."
        }
    }

    private func transactionIdentifiers(_ transaction: SKPaymentTransaction) -> [String] {
        [transaction.transactionIdentifier, transaction.original?.transactionIdentifier]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
    }

    private func rememberPreexisting(_ transaction: SKPaymentTransaction) {
        preexistingObjects.insert(ObjectIdentifier(transaction))
        preexistingIDs.formUnion(transactionIdentifiers(transaction))
    }

    private func forgetPreexisting(_ transaction: SKPaymentTransaction) {
        preexistingObjects.remove(ObjectIdentifier(transaction))
    }

    nonisolated func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        let batch = transactions
        Task { @MainActor in
            if !self.queueDelivered && self.expected.isEmpty {
                self.queueDelivered = true
                for transaction in batch { self.rememberPreexisting(transaction) }
            } else if !self.acceptingPurchases {
                for transaction in batch { self.rememberPreexisting(transaction) }
            }
            self.enqueue(batch)
        }
    }
}

/// Kept off the main-actor class so StoreKit 1 can call this delegate.
@objc(TetoStoreProductFetcher)
final class TetoStoreProductFetcher: NSObject, SKProductsRequestDelegate {
    static let shared = TetoStoreProductFetcher()
    private var request: SKProductsRequest?
    var onFinish: (([SKProduct], [String]) -> Void)?
    var onFail: (() -> Void)?

    func start(_ identifiers: Set<String>) {
        let begin = {
            let next = SKProductsRequest(productIdentifiers: identifiers)
            next.delegate = self
            self.request = next
            next.start()
        }
        if Thread.isMainThread {
            begin()
        } else {
            DispatchQueue.main.async(execute: begin)
        }
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let loaded = response.products
        let invalid = response.invalidProductIdentifiers
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.request != nil, request !== self.request { return }
            self.request = nil
            self.onFinish?(loaded, invalid)
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.request != nil, request !== self.request { return }
            self.request = nil
            self.onFail?()
        }
    }
}

private enum CreditOutcome {
    case savedNew
    case alreadySaved
    case notSaved
}

private final class PurchaseWait {
    var continuation: CheckedContinuation<String?, Never>?
    var settled = false
    var message: String?
}
