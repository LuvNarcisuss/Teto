import Combine
import UIKit
import WebKit

@main final class TetoAppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication, configurationForConnecting session: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let configuration = UISceneConfiguration(name: "Teto", sessionRole: session.role)
    configuration.sceneClass = UIWindowScene.self
    configuration.delegateClass = TetoSceneDelegate.self
    return configuration
  }
}
final class TetoSceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  private var coordinator: TetoCoordinator?
  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions
  ) {
    guard let scene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: scene)
    window.frame = scene.coordinateSpace.bounds
    window.backgroundColor = TetoTheme.background
    self.window = window
    coordinator = TetoCoordinator(window: window)
    coordinator?.start()
    window.makeKeyAndVisible()
  }
}
@MainActor final class TetoCoordinator {
  let store = AppStore()
  private let window: UIWindow
  private let backdrop = StudioCanvas()
  private var token: AnyCancellable?
  init(window: UIWindow) {
    self.window = window
    backdrop.isUserInteractionEnabled = false
    window.addSubview(backdrop)
    backdrop.pin(to: window)
  }
  private func install(_ controller: UIViewController) {
    window.rootViewController = controller
    window.sendSubviewToBack(backdrop)
  }
  func start() {
    let loading = UIViewController()
    loading.overrideUserInterfaceStyle = .light
    loading.view.backgroundColor = TetoTheme.background
    let brand = UIImageView(image: TetoIcon.wordmark)
    brand.contentMode = .scaleAspectFit
    brand.layer.cornerRadius = 36
    brand.layer.cornerCurve = .continuous
    brand.clipsToBounds = true
    brand.isAccessibilityElement = true
    brand.accessibilityLabel = "Teto"
    loading.view.addSubview(brand)
    brand.translatesAutoresizingMaskIntoConstraints = false
    let spinner = UIActivityIndicatorView(style: .medium)
    spinner.color = TetoTheme.emerald
    spinner.accessibilityLabel = "Loading your dances"
    loading.view.addSubview(spinner)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      brand.centerXAnchor.constraint(equalTo: loading.view.centerXAnchor),
      brand.centerYAnchor.constraint(equalTo: loading.view.centerYAnchor, constant: -24),
      brand.widthAnchor.constraint(equalToConstant: 160),
      brand.heightAnchor.constraint(equalToConstant: 160),
      spinner.centerXAnchor.constraint(equalTo: loading.view.centerXAnchor),
      spinner.topAnchor.constraint(equalTo: brand.bottomAnchor, constant: 24),
    ])
    spinner.startAnimating()
    install(loading)
    token = store.$accountExitRevision.dropFirst().receive(on: DispatchQueue.main).sink {
      [weak self] _ in self?.showEntry(welcome: false)
    }
    Task {
      await store.load()
      showEntry(welcome: true)
    }
  }
  func showEntry(welcome: Bool) {
    let entry = EntryController(store: store, welcome: welcome)
    entry.onContinue = { [weak self] in
      guard let self else { return }
      self.install(TetoTabController(store: self.store))
    }
    let nav = UINavigationController(rootViewController: entry)
    TetoNavigation.style(nav)
    install(nav)
  }
}
/// Bottom-tab control drawn as an icon over an italic word, without a system button label.
private final class DockItem: UIControl {
  init(icon: TetoIcon, title: String) {
    super.init(frame: .zero)
    let image = UIImageView(image: icon.image(size: 30))
    image.contentMode = .scaleAspectFit
    image.isUserInteractionEnabled = false
    let caption = UILabel()
    caption.text = title
    caption.font = TetoTheme.font(10, title: true)
    caption.textColor = TetoTheme.ink
    caption.textAlignment = .center
    caption.adjustsFontSizeToFitWidth = true
    caption.minimumScaleFactor = 0.7
    caption.isUserInteractionEnabled = false
    caption.layer.shadowColor = UIColor.white.cgColor
    caption.layer.shadowOpacity = 0.95
    caption.layer.shadowRadius = 2
    caption.layer.shadowOffset = .zero
    caption.layer.masksToBounds = false
    image.layer.shadowColor = UIColor.white.cgColor
    image.layer.shadowOpacity = 0.9
    image.layer.shadowRadius = 2.5
    image.layer.shadowOffset = .zero
    image.layer.masksToBounds = false
    let column = UIStackView(arrangedSubviews: [image, caption])
    column.axis = .vertical
    column.alignment = .center
    column.spacing = 1
    column.isUserInteractionEnabled = false
    addSubview(column)
    column.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      column.centerXAnchor.constraint(equalTo: centerXAnchor),
      column.centerYAnchor.constraint(equalTo: centerYAnchor),
      caption.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -2),
      image.widthAnchor.constraint(equalToConstant: 30),
      image.heightAnchor.constraint(equalToConstant: 30),
    ])
    isAccessibilityElement = true
    accessibilityLabel = title
    accessibilityTraits = .button
    addTarget(self, action: #selector(pressDown), for: .touchDown)
    addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }
  @objc private func pressDown() {
    guard !UIAccessibility.isReduceMotionEnabled else { return }
    UIView.animate(withDuration: 0.12, delay: 0, options: [.allowUserInteraction]) {
      self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
    }
  }
  @objc private func pressUp() {
    UIView.animate(
      withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4,
      options: [.allowUserInteraction]
    ) { self.transform = .identity }
  }
}

final class TetoTabController: UIViewController, UINavigationControllerDelegate {
  let store: AppStore
  private var pages: [UINavigationController] = []
  private let dock = UIView(), bubble = UIView(), buttons = UIStackView()
  private var index = 0
  private var draggingDock = false
  private var movingBubble = false
  private var bubbleMove = 0
  private var selectedLeading: NSLayoutConstraint?
  private weak var commentSheet: UIView?
  private var commentCoversDock = false
  init(store: AppStore) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }
  override func viewDidLoad() {
    super.viewDidLoad()
    overrideUserInterfaceStyle = .light
    view.backgroundColor = .clear
    view.clipsToBounds = false
    let screens: [UIViewController] = [
      DanceDiscoveryController(store: store), PhraseListController(store: store),
      PartyDiscoveryController(store: store), ChatsController(store: store), MeController(store: store),
    ]
    pages = screens.map {
      let nav = UINavigationController(rootViewController: $0)
      TetoNavigation.style(nav)
      nav.delegate = self
      nav.additionalSafeAreaInsets.bottom = 78
      return nav
    }
    dock.backgroundColor = .clear
    dock.layer.cornerRadius = 30
    dock.layer.cornerCurve = .continuous
    dock.layer.borderWidth = 1
    dock.layer.borderColor = UIColor.white.withAlphaComponent(0.55).cgColor
    dock.clipsToBounds = false
    view.addSubview(dock)
    dock.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      dock.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      dock.trailingAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      dock.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6),
      dock.heightAnchor.constraint(equalToConstant: 66),
    ])
    let frost = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))
    frost.isUserInteractionEnabled = false
    frost.layer.cornerRadius = 30
    frost.layer.cornerCurve = .continuous
    frost.clipsToBounds = true
    dock.addSubview(frost)
    frost.pin(to: dock)
    let veil = UIView()
    veil.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    veil.isUserInteractionEnabled = false
    frost.contentView.addSubview(veil)
    veil.pin(to: frost.contentView)
    bubble.backgroundColor = .clear
    bubble.rounded(28)
    bubble.layer.borderWidth = 1
    bubble.layer.borderColor = UIColor.white.withAlphaComponent(0.72).cgColor
    let glass = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    glass.isUserInteractionEnabled = false
    bubble.addSubview(glass)
    glass.pin(to: bubble)
    let tint = UIView()
    tint.backgroundColor = TetoTheme.lime.withAlphaComponent(0.16)
    tint.isUserInteractionEnabled = false
    glass.contentView.addSubview(tint)
    tint.pin(to: glass.contentView)
    dock.addSubview(bubble)
    bubble.translatesAutoresizingMaskIntoConstraints = false
    selectedLeading = bubble.leadingAnchor.constraint(equalTo: dock.leadingAnchor, constant: 5)
    NSLayoutConstraint.activate([
      selectedLeading!, bubble.topAnchor.constraint(equalTo: dock.topAnchor, constant: 5),
      bubble.bottomAnchor.constraint(equalTo: dock.bottomAnchor, constant: -5),
      bubble.widthAnchor.constraint(equalTo: dock.widthAnchor, multiplier: 0.2, constant: -6),
    ])
    buttons.axis = .horizontal
    buttons.distribution = .fillEqually
    dock.addSubview(buttons)
    buttons.pin(to: dock, insets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
    for (i, pair) in [
      (TetoIcon.live, "Live"), (.phrases, "Phrases"), (.voice, "Voice"), (.chats, "Chats"), (.me, "Me"),
    ]
      .enumerated()
    {
      let item = DockItem(icon: pair.0, title: pair.1)
      item.addAction(UIAction { [weak self] _ in self?.select(i) }, for: .touchUpInside)
      buttons.addArrangedSubview(item)
    }
    let pan = UIPanGestureRecognizer(target: self, action: #selector(dragDock(_:)))
    dock.addGestureRecognizer(pan)
    select(0)
  }
  @objc private func dragDock(_ gesture: UIPanGestureRecognizer) {
    let width = dock.bounds.width
    guard width > 0 else { return }
    let segment = width / 5
    let leading = min(5 + 4 * segment, max(5, gesture.location(in: dock).x - (segment - 6) / 2))
    let nearest = min(4, max(0, Int(((leading - 5) / segment).rounded())))
    switch gesture.state {
    case .began, .changed:
      draggingDock = true
      selectedLeading?.constant = leading
      let slot = 5 + CGFloat(nearest) * segment
      let pull = min(0.06, abs(leading - slot) / segment * 0.1)
      bubble.transform = CGAffineTransform(scaleX: 1 + pull, y: 1 - pull * 0.45)
      showPage(nearest)
    case .ended, .cancelled, .failed:
      draggingDock = false
      select(nearest)
    default:
      break
    }
  }
  private func select(_ next: Int) {
    let previous = index
    showPage(next)
    guard dock.bounds.width > 0 else { return }
    let destination = 5 + CGFloat(index) * dock.bounds.width / 5
    bubbleMove += 1
    let move = bubbleMove
    let finish = {
      self.selectedLeading?.constant = destination
      self.dock.layoutIfNeeded()
      self.bubble.transform = .identity
    }
    if UIAccessibility.isReduceMotionEnabled {
      movingBubble = false
      finish()
      return
    }
    let alreadyThere = previous == index && bubble.transform.isIdentity
    if alreadyThere {
      movingBubble = false
      finish()
      return
    }
    movingBubble = true
    // One spring carries the bubble into place. No second pose, so it does not stop midway.
    if previous != index {
      let stretch = min(1.045, 1 + 0.02 * CGFloat(abs(index - previous)))
      bubble.transform = CGAffineTransform(scaleX: stretch, y: 2 - stretch)
    }
    UIView.animate(
      withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.15,
      options: [.allowUserInteraction, .beginFromCurrentState]
    ) {
      finish()
    } completion: { _ in
      if self.bubbleMove == move { self.movingBubble = false }
    }
  }
  private func showPage(_ next: Int) {
    guard children.isEmpty || next != index else { return }
    if !children.isEmpty {
      let old = pages[index]
      old.willMove(toParent: nil)
      old.view.removeFromSuperview()
      old.removeFromParent()
    }
    index = next
    let nav = pages[next]
    addChild(nav)
    view.insertSubview(nav.view, at: 0)
    nav.view.pin(to: view)
    nav.didMove(toParent: self)
    for (i, button) in buttons.arrangedSubviews.enumerated() {
      button.accessibilityTraits = i == next ? [.button, .selected] : .button
    }
    let covered = nav.topViewController !== nav.viewControllers.first
    applyDock(covered: covered, nav: nav)
  }
  func navigationController(
    _ navigationController: UINavigationController, willShow viewController: UIViewController,
    animated: Bool
  ) {
    guard pages.indices.contains(index), navigationController === pages[index] else { return }
    let covered = viewController !== navigationController.viewControllers.first
    let apply = { self.applyDock(covered: covered, nav: navigationController) }
    guard animated, let coordinator = navigationController.transitionCoordinator else {
      apply()
      return
    }
    coordinator.animate(alongsideTransition: { _ in apply() }) { context in
      guard context.isCancelled else { return }
      let stillCovered = navigationController.topViewController !== navigationController.viewControllers.first
      self.applyDock(covered: stillCovered, nav: navigationController)
    }
  }
  /// Home pages keep the dock. A pushed page, including a friend chat, covers it.
  private func applyDock(covered: Bool, nav: UINavigationController) {
    nav.additionalSafeAreaInsets.bottom = (covered || commentCoversDock) ? 0 : 78
    dock.alpha = covered ? 0 : 1
    dock.isUserInteractionEnabled = !covered
    dock.accessibilityElementsHidden = covered
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let commentSheet { view.bringSubviewToFront(commentSheet) }
    if bubble.bounds.height > 1 {
      bubble.layer.cornerRadius = bubble.bounds.height / 2
    }
    guard !draggingDock, !movingBubble, dock.bounds.width > 0 else { return }
    selectedLeading?.constant = 5 + CGFloat(index) * dock.bounds.width / 5
  }
  /// Video stage stays under the dock; the ivory sheet is placed over Live / Voice / Chats / Me.
  /// The comment panel is a child here because its view lives on this page.
  func attachCommentOverlay(
    panel: UIViewController, backdrop: UIView, stage: UIView, host: UIView
  ) {
    addChild(panel)
    commentSheet = host
    view.insertSubview(backdrop, belowSubview: dock)
    view.insertSubview(stage, aboveSubview: backdrop)
    view.addSubview(host)
    panel.didMove(toParent: self)
  }
  /// Drops the dock inset so the comment field can sit over Live / Voice / Chats / Me.
  func setCommentOverlayActive(_ active: Bool) {
    commentCoversDock = active
    if active {
      pages.forEach { $0.additionalSafeAreaInsets.bottom = 0 }
    } else {
      commentSheet = nil
      for nav in pages {
        let covered = nav.topViewController !== nav.viewControllers.first
        nav.additionalSafeAreaInsets.bottom = covered ? 0 : 78
      }
    }
  }
}
final class EntryController: TetoScreen, UITextViewDelegate {
  var onContinue: (() -> Void)?
  private let scroll = UIScrollView()
  private let content = UIStackView()
  private var welcome: Bool
  private var accepted = false
  init(store: AppStore, welcome: Bool) {
    self.welcome = welcome
    super.init(store: store)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }
  override func build() {
    scroll.contentInsetAdjustmentBehavior = .never
    scroll.showsVerticalScrollIndicator = false
    view.addSubview(scroll)
    scroll.translatesAutoresizingMaskIntoConstraints = false
    content.axis = .vertical
    content.spacing = 16
    scroll.addSubview(content)
    content.translatesAutoresizingMaskIntoConstraints = false
    let preferredWidth = content.widthAnchor.constraint(
      equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40)
    preferredWidth.priority = .defaultHigh
    NSLayoutConstraint.activate([
      scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      scroll.contentLayoutGuide.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
      content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 12),
      content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
      content.centerXAnchor.constraint(equalTo: scroll.contentLayoutGuide.centerXAnchor),
      content.widthAnchor.constraint(lessThanOrEqualToConstant: 440),
      content.widthAnchor.constraint(lessThanOrEqualTo: scroll.frameLayoutGuide.widthAnchor, constant: -40),
      content.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor, constant: -32),
      preferredWidth,
    ])
  }
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(true, animated: false)
    super.viewWillAppear(animated)
  }
  override func refresh() {
    guard isViewLoaded else { return }
    content.arrangedSubviews.forEach { $0.removeFromSuperview() }
    let logo = UIImageView(image: TetoIcon.wordmark)
    logo.contentMode = .scaleAspectFit
    logo.layer.cornerRadius = 26
    logo.layer.cornerCurve = .continuous
    logo.clipsToBounds = true
    logo.isAccessibilityElement = true
    logo.accessibilityLabel = "Teto"
    let mark = UIView()
    logo.translatesAutoresizingMaskIntoConstraints = false
    mark.addSubview(logo)
    NSLayoutConstraint.activate([
      logo.topAnchor.constraint(equalTo: mark.topAnchor),
      logo.bottomAnchor.constraint(equalTo: mark.bottomAnchor),
      logo.centerXAnchor.constraint(equalTo: mark.centerXAnchor),
      logo.widthAnchor.constraint(equalToConstant: 112),
      logo.heightAnchor.constraint(equalToConstant: 112),
    ])
    content.addArrangedSubview(mark)
    content.setCustomSpacing(4, after: mark)
    let dancers = UIImageView(image: UIImage(named: "TetoEntryDance"))
    dancers.contentMode = .scaleAspectFit
    dancers.isAccessibilityElement = false
    content.addArrangedSubview(dancers)
    // Both views must share the stack hierarchy before activating this constraint.
    dancers.heightAnchor.constraint(equalTo: content.widthAnchor, multiplier: 0.78).isActive = true
    let title = label(welcome ? "Move to your\nrhythm." : "Find your\ndance people.", 36, title: true)
    title.textAlignment = .center
    title.accessibilityTraits = .header
    title.setContentCompressionResistancePriority(.required, for: .vertical)
    content.addArrangedSubview(title)
    content.setCustomSpacing(8, after: title)
    let subtitle = label(
      welcome ? "Share your dance. Find your people." : "A little practice. A shared rhythm.",
      18, TetoTheme.muted)
    subtitle.textAlignment = .center
    subtitle.setContentCompressionResistancePriority(.required, for: .vertical)
    content.addArrangedSubview(subtitle)
    let space = UIView()
    space.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
    space.setContentHuggingPriority(.init(1), for: .vertical)
    content.addArrangedSubview(space)
    content.setCustomSpacing(0, after: space)
    if let error = store.loadError {
      content.addArrangedSubview(label(error))
      content.addArrangedSubview(
        actionButton("Try again", icon: .refresh) { [weak self] in
          Task {
            await self?.store.load()
            self?.refresh()
          }
        })
      return
    }
    if welcome {
      content.addArrangedSubview(
        actionButton("Get started", icon: .forward, tone: .lime) { [weak self] in
          self?.welcome = false
          self?.refresh()
          self?.scroll.setContentOffset(.zero, animated: false)
        })
      return
    }
    let box = iconButton(
      accepted ? .checkboxOn : .checkbox,
      accepted ? "Agreement checked" : "Agree to the agreements", size: 28
    ) { [weak self] in
      guard let self else { return }
      self.accepted.toggle()
      self.refresh()
    }
    box.accessibilityTraits = accepted ? [.button, .selected] : .button
    box.widthAnchor.constraint(equalToConstant: 44).isActive = true
    let row = stack([box, agreementText()], axis: .horizontal, spacing: 10)
    row.alignment = .top
    content.addArrangedSubview(row)
    content.addArrangedSubview(
      actionButton("Let's dance", icon: .forward, tone: .lime) { [weak self] in self?.continueEntry() }
    )
  }
  private func agreementText() -> UITextView {
    let text = UITextView()
    text.backgroundColor = .clear
    text.isEditable = false
    text.isSelectable = true
    text.isScrollEnabled = false
    text.delegate = self
    text.textContainerInset = .zero
    text.textContainer.lineFragmentPadding = 0
    text.adjustsFontForContentSizeCategory = true
    text.linkTextAttributes = [
      .foregroundColor: TetoTheme.emerald,
      .underlineStyle: NSUnderlineStyle.single.rawValue,
    ]
    let bodyStyle = NSMutableParagraphStyle()
    bodyStyle.lineSpacing = 3
    let base: [NSAttributedString.Key: Any] = [
      .font: TetoTheme.font(16),
      .foregroundColor: TetoTheme.ink,
      .paragraphStyle: bodyStyle,
    ]
    let body = NSMutableAttributedString(
      string: "I have read and agree to the ", attributes: base)
    for (index, document) in AgreementDocument.allCases.enumerated() {
      if index > 0 {
        body.append(NSAttributedString(string: " and ", attributes: base))
      }
      var link = base
      link[.link] = URL(string: "teto-agreement://agreement/\(document.rawValue)")
      link[.foregroundColor] = TetoTheme.emerald
      link[.underlineStyle] = NSUnderlineStyle.single.rawValue
      body.append(NSAttributedString(string: document.title, attributes: link))
    }
    body.append(NSAttributedString(string: ".", attributes: base))
    text.attributedText = body
    text.accessibilityLabel =
      "I have read and agree to the Terms of Service and Privacy Policy."
    return text
  }
  func textView(
    _ textView: UITextView,
    shouldInteractWith url: URL,
    in characterRange: NSRange,
    interaction: UITextItemInteraction
  ) -> Bool {
    if #available(iOS 17.0, *) {
      return true
    }
    presentAgreement(for: url)
    return false
  }
  @available(iOS 17.0, *)
  func textView(
    _ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction
  ) -> UIAction? {
    guard case .link(let url) = textItem.content, let document = agreementDocument(for: url) else {
      return defaultAction
    }
    return UIAction { [weak self] _ in
      guard let self else { return }
      self.presentScreen(AgreementController(store: self.store, document: document))
    }
  }
  private func presentAgreement(for url: URL) {
    guard let document = agreementDocument(for: url) else { return }
    presentScreen(AgreementController(store: store, document: document))
  }
  private func agreementDocument(for url: URL) -> AgreementDocument? {
    guard url.scheme == "teto-agreement",
      let name = url.path.split(separator: "/").last
    else { return nil }
    return AgreementDocument(rawValue: String(name))
  }
  private func continueEntry() {
    guard accepted else {
      askToAgree()
      return
    }
    enterApp()
  }
  private func askToAgree() {
    let agree = actionButton("Agree and continue", primary: true) { [weak self] in
      guard let self else { return }
      self.accepted = true
      self.dismissCard {
        self.refresh()
        self.enterApp()
      }
    }
    let decline = actionButton("Disagree") { [weak self] in self?.dismissCard() }
    showCard([agreementReminder(), agree, decline])
  }
  private func agreementReminder() -> UITextView {
    let text = UITextView()
    text.backgroundColor = .clear
    text.isEditable = false
    text.isSelectable = true
    text.isScrollEnabled = false
    text.delegate = self
    text.textContainerInset = .zero
    text.textContainer.lineFragmentPadding = 0
    text.adjustsFontForContentSizeCategory = true
    text.linkTextAttributes = [
      .foregroundColor: TetoTheme.emerald,
      .underlineStyle: NSUnderlineStyle.single.rawValue,
    ]
    let bodyStyle = NSMutableParagraphStyle()
    bodyStyle.lineSpacing = 3
    let base: [NSAttributedString.Key: Any] = [
      .font: TetoTheme.font(16),
      .foregroundColor: TetoTheme.ink,
      .paragraphStyle: bodyStyle,
    ]
    let body = NSMutableAttributedString(
      string: "Please read and agree to the ", attributes: base)
    for (index, document) in AgreementDocument.allCases.enumerated() {
      if index > 0 {
        body.append(NSAttributedString(string: " and ", attributes: base))
      }
      var link = base
      link[.link] = URL(string: "teto-agreement://agreement/\(document.rawValue)")
      link[.foregroundColor] = TetoTheme.emerald
      link[.underlineStyle] = NSUnderlineStyle.single.rawValue
      body.append(NSAttributedString(string: document.title, attributes: link))
    }
    body.append(NSAttributedString(string: " before you continue.", attributes: base))
    text.attributedText = body
    text.accessibilityLabel =
      "Please read and agree to the Terms of Service and Privacy Policy before you continue."
    text.frame.size.width = 284
    let height = text.sizeThatFits(CGSize(width: 284, height: 240)).height
    text.heightAnchor.constraint(equalToConstant: max(48, height)).isActive = true
    return text
  }
  private func enterApp() {
    Task {
      if await store.acceptUserAgreement() {
        onContinue?()
      } else {
        message(store.lastSaveError ?? "The agreements could not be saved. Please try again.")
      }
    }
  }
}
final class AgreementController: TetoScreen, WKNavigationDelegate {
  let document: AgreementDocument
  private var showingSavedCopy = false
  init(store: AppStore, document: AgreementDocument) {
    self.document = document
    super.init(store: store, title: document.title)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }
  override func build() {
    let configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = .nonPersistent()
    let web = WKWebView(frame: .zero, configuration: configuration)
    web.navigationDelegate = self
    view.addSubview(web)
    web.pin(to: view)
    web.load(URLRequest(url: document.onlineURL, timeoutInterval: 20))
  }
  private func loadSavedCopy(in web: WKWebView) {
    guard !showingSavedCopy else { return }
    showingSavedCopy = true
    navigationItem.prompt = "Saved copy"
    guard let url = document.fileURL else {
      message("This agreement could not be opened.")
      return
    }
    web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
  }
  func webView(
    _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    guard let url = navigationAction.request.url else {
      decisionHandler(.cancel)
      return
    }
    if showingSavedCopy {
      decisionHandler(url.isFileURL && url.standardizedFileURL == document.fileURL?.standardizedFileURL ? .allow : .cancel)
      return
    }
    if navigationAction.targetFrame?.isMainFrame == false {
      decisionHandler(url.scheme == "https" || url.absoluteString == "about:blank" ? .allow : .cancel)
      return
    }
    let documentPath = document.onlineURL.path
    if url.scheme == "https", url.host == "docs.google.com",
      url.path == documentPath || url.path.hasPrefix(documentPath + "/") {
      decisionHandler(.allow)
    } else {
      decisionHandler(.cancel)
      // A private document redirects to sign-in. Keep the agreement readable without an account.
      if url.host == "accounts.google.com" {
        loadSavedCopy(in: webView)
      }
    }
  }
  func webView(
    _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
    decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
  ) {
    if navigationResponse.isForMainFrame,
      let response = navigationResponse.response as? HTTPURLResponse,
      !(200..<300).contains(response.statusCode) {
      decisionHandler(.cancel)
      loadSavedCopy(in: webView)
      return
    }
    decisionHandler(.allow)
  }
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    if (error as NSError).code != NSURLErrorCancelled { loadSavedCopy(in: webView) }
  }
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    if (error as NSError).code != NSURLErrorCancelled { loadSavedCopy(in: webView) }
  }
}
