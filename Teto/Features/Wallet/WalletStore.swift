import Combine
import Foundation

@MainActor
final class WalletStore: ObservableObject {
    @Published private(set) var snapshot = WalletSnapshot()
    @Published private(set) var isBusy = false
    @Published private(set) var prices: [String: String] = [:]
    private let purchasing = StoreKit1Purchasing()

    init() {
        purchasing.onChange = { [weak self] ledger, prices in
            self?.snapshot = ledger.snapshot
            self?.prices = prices
        }
    }

    func priceText(for package: WalletPackage) -> String {
        prices[package.storeProductID] ?? "See price"
    }

    func prepareProducts() {
        purchasing.reloadProductsIfNeeded()
    }

    func adopt(_ ledger: WalletLedger) {
        purchasing.adopt(ledger)
    }

    func setPersist(_ persist: @escaping (WalletLedger) async -> Bool) {
        purchasing.setPersist(persist)
    }

    func startPayments() async {
        await purchasing.start()
    }

    func stopPayments() async {
        await purchasing.stop()
    }

    func clearAccountMemory() {
        purchasing.clearMemory()
    }

    func purchase(_ package: WalletPackage) async -> String? {
        guard !isBusy else { return "Please wait for the current request to finish." }
        isBusy = true
        defer { isBusy = false }
        return await purchasing.purchase(package)
    }

    func send(_ gift: DanceGift, quantity: Int, roomID: String) async -> String? {
        guard !roomID.isEmpty, (1...99).contains(quantity) else {
            return "Please check the quantity and try again."
        }
        return await purchasing.spend(gift, quantity: quantity)
    }
}
