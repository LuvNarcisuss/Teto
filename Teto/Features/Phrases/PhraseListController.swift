import UIKit

final class PhraseListController: StackScreen, UIScrollViewDelegate {
    private var createButton: UIButton?
    private var tiles: [PhraseFigureCard] = []
    private var tileSync: DispatchWorkItem?

    init(store: AppStore) {
        super.init(store: store, title: "Phrases")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

    override func build() {
        super.build()
        navigationItem.leftBarButtonItem = barButton(tetoMark())
        pinListUnderDock()
        let create = iconButton(.plus, "New phrase") { [weak self] in
            guard let self else { return }
            self.push(PhraseEditorController(store: self.store, mode: .create))
        }
        createButton = create
        create.backgroundColor = TetoTheme.lime
        create.rounded(26)
        view.addSubview(create)
        create.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            create.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            create.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            create.widthAnchor.constraint(equalToConstant: 52),
            create.heightAnchor.constraint(equalToConstant: 52),
        ])
        scroll.contentInset.bottom = 88
        scroll.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scheduleTiles()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tiles.forEach { $0.setPlaying(false) }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let createButton { view.bringSubviewToFront(createButton) }
        scheduleTiles()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) { syncTiles() }

    override func refresh() {
        guard isViewLoaded else { return }
        clear()
        content.addArrangedSubview(
            label("Count a phrase, then keep the ones you are learning.", 15, TetoTheme.muted))
        let feed = store.phraseFeed()
        let phrases = feed.kept + feed.yours + feed.catalog
        tiles = []
        if phrases.isEmpty {
            content.addArrangedSubview(label("No phrases to read right now.", 16, TetoTheme.muted))
            return
        }
        let columns = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? 1 : 2
        let spacing: CGFloat = 10
        for start in stride(from: 0, to: phrases.count, by: columns) {
            let row = stack(axis: .horizontal, spacing: spacing)
            row.distribution = .fillEqually
            row.alignment = .fill
            row.setContentCompressionResistancePriority(.required, for: .vertical)
            row.setContentHuggingPriority(.required, for: .vertical)
            for phrase in phrases[start..<min(start + columns, phrases.count)] {
                row.addArrangedSubview(tile(phrase))
            }
            if row.arrangedSubviews.count < columns { row.addArrangedSubview(UIView()) }
            content.addArrangedSubview(row)
            let height = row.heightAnchor.constraint(
                equalTo: content.widthAnchor,
                multiplier: 1.25 / CGFloat(columns),
                constant: -(spacing * 1.25 * CGFloat(columns - 1) / CGFloat(columns)))
            height.priority = .required
            height.isActive = true
        }
        scheduleTiles()
    }

    private func tile(_ phrase: DancePhrase) -> UIView {
        let card = PhraseFigureCard()
        card.bind(phrase, avatar: phraseAvatarImage(phrase, store: store), coverURL: store.phraseCoverURL(for: phrase))
        card.onTap = { [weak self] in self?.open(phrase) }
        card.onAvatar = { [weak self] in self?.openAuthor(phrase) }
        let press = UILongPressGestureRecognizer(target: self, action: #selector(longPressTile(_:)))
        card.addGestureRecognizer(press)
        tiles.append(card)
        return card
    }

    private func scheduleTiles() {
        tileSync?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.syncTiles() }
        tileSync = work
        DispatchQueue.main.async(execute: work)
    }

    private func syncTiles() {
        let active = view.window != nil && presentedViewController == nil
        let visible = scroll.bounds
        for tile in tiles {
            let frame = tile.convert(tile.bounds, to: scroll)
            tile.setPlaying(active && frame.intersects(visible))
        }
    }

    @objc private func longPressTile(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let tile = gesture.view as? PhraseFigureCard,
            let phrase = store.phrase(id: tile.phraseID)
        else { return }
        longPress(on: phrase)
    }

    private func open(_ phrase: DancePhrase) {
        guard store.phrase(id: phrase.id) != nil else { return }
        push(PhraseDetailController(store: store, phraseID: phrase.id))
    }

    private func openAuthor(_ phrase: DancePhrase) {
        push(CreatorController(store: store, creator: phraseAuthor(phrase, store: store)))
    }

    private func longPress(on phrase: DancePhrase) {
        if phrase.authorID == "local-owner" {
            let edit = actionButton("Edit phrase", icon: .check) { [weak self] in
                self?.dismissCard {
                    guard let self else { return }
                    self.push(PhraseEditorController(store: self.store, mode: .edit(phrase)))
                }
            }
            let delete = actionButton("Delete phrase", icon: .trash, tone: .danger) { [weak self] in
                self?.dismissCard { self?.confirmDelete(phrase) }
            }
            showCard([label(phrase.title, 22, title: true), edit, delete])
        } else {
            let report = actionButton("Report phrase", icon: .flag) { [weak self] in
                self?.dismissCard { self?.report(phrase) }
            }
            let block = actionButton("Block dancer", icon: .block, tone: .danger) { [weak self] in
                self?.dismissCard { self?.block(phrase) }
            }
            showCard([label(phrase.title, 22, title: true), report, block])
        }
    }

    private func confirmDelete(_ phrase: DancePhrase) {
        confirm(
            "Delete this phrase?",
            message: "This removes the phrase from this device. Phrases that grew from it keep their own counts.",
            destructive: true, button: "Delete"
        ) { [weak self] in
            guard let self else { return }
            Task {
                if await self.store.deletePhrase(id: phrase.id) == false {
                    self.message(self.store.lastSaveError ?? "This phrase could not be saved. Please try again.")
                }
            }
        }
    }

    private func report(_ phrase: DancePhrase) {
        let safety = SafetyController(
            store: store,
            target: .phrase(
                id: phrase.id, title: phrase.title, authorID: phrase.authorID, authorName: phrase.authorName),
            reporting: true)
        presentScreen(safety)
    }

    private func block(_ phrase: DancePhrase) {
        let creator = phraseAuthor(phrase, store: store)
        confirm(
            "Block " + creator.name + "?",
            message:
                "Their phrases, live videos, short videos, and voice rooms will be hidden. You can unblock them from Blocked in Settings.",
            destructive: true, button: "Block"
        ) { [weak self] in
            guard let self else { return }
            Task {
                if await self.store.blockCreator(creator) == false {
                    self.message(self.store.lastSaveError ?? "Please try again.")
                }
            }
        }
    }
}

@MainActor
private final class PhraseCard: UIControl {
    var phraseID = ""
    let portraitButton = UIButton(type: .custom)
    private let body = UIStackView()

    init(phrase: DancePhrase, marks: [Bool]) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.94)
        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
        layer.borderWidth = 1.5
        layer.borderColor = TetoTheme.lime.cgColor
        clipsToBounds = true
        let portrait = roundPortrait(
            asset: DancerPortraits.asset(forName: phrase.authorName), size: 52, personID: phrase.authorID)
        portrait.isUserInteractionEnabled = false
        portraitButton.addSubview(portrait)
        portrait.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            portraitButton.widthAnchor.constraint(equalToConstant: 52),
            portraitButton.heightAnchor.constraint(equalToConstant: 52),
            portrait.leadingAnchor.constraint(equalTo: portraitButton.leadingAnchor),
            portrait.trailingAnchor.constraint(equalTo: portraitButton.trailingAnchor),
            portrait.topAnchor.constraint(equalTo: portraitButton.topAnchor),
            portrait.bottomAnchor.constraint(equalTo: portraitButton.bottomAnchor),
        ])
        portraitButton.accessibilityLabel = "Open \(phrase.authorName)'s profile"
        let titleLabel = label(phrase.title, 20, title: true)
        titleLabel.numberOfLines = 2
        let countLabel = label(phrase.eights.first?.first ?? "", 15, TetoTheme.muted)
        countLabel.numberOfLines = 2
        let metaLabel = label(
            "\(phrase.style.title) · \(phrase.tempo.title) · \(phrase.eightCountLabel)", 13, TetoTheme.emerald)
        let fromLabel = label(phrase.parentTitle.map { "From \($0)" } ?? "", 13, TetoTheme.muted)
        fromLabel.isHidden = phrase.parentTitle == nil
        let words = stack([titleLabel, countLabel, metaLabel, fromLabel, PhrasePips(marks: marks)], spacing: 4)
        words.isUserInteractionEnabled = false
        body.axis = .vertical
        body.spacing = 4
        body.isUserInteractionEnabled = false
        for view in words.arrangedSubviews {
            body.addArrangedSubview(view)
        }
        addSubview(body)
        addSubview(portraitButton)
        body.translatesAutoresizingMaskIntoConstraints = false
        portraitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            portraitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            portraitButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            body.leadingAnchor.constraint(equalTo: portraitButton.trailingAnchor, constant: 12),
            body.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            body.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            body.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
        ])
        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentHuggingPriority(.required, for: .vertical)
        let learned = marks.filter { $0 }.count
        isAccessibilityElement = true
        accessibilityLabel =
            "\(phrase.title), \(phrase.style.title), \(phrase.tempo.title), \(phrase.eightCountLabel), \(learned) of \(marks.count) sections learned"
        accessibilityHint = "Opens the phrase. Long press for more actions."
        accessibilityTraits = .button
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

    /// The stack view otherwise gives this card no height, so the list looks empty and taps miss.
    override var intrinsicContentSize: CGSize {
        let width = bounds.width > 1 ? bounds.width : 340
        let fitted = body.systemLayoutSizeFitting(
            CGSize(width: width - 92, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: UIView.noIntrinsicMetric, height: max(112, fitted.height + 28))
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01, bounds.contains(point) else { return nil }
        let local = portraitButton.convert(point, from: self)
        if portraitButton.point(inside: local, with: event) { return portraitButton }
        return self
    }
}

@MainActor
final class PhrasePips: UIStackView {
    init(marks: [Bool]) {
        super.init(frame: .zero)
        axis = .horizontal
        spacing = 6
        alignment = .center
        for mark in marks {
            let pip = UIView()
            pip.backgroundColor = mark ? TetoTheme.emerald : UIColor.white
            pip.layer.cornerRadius = 5
            pip.layer.borderWidth = mark ? 0 : 1
            pip.layer.borderColor = TetoTheme.emerald.cgColor
            pip.translatesAutoresizingMaskIntoConstraints = false
            pip.widthAnchor.constraint(equalToConstant: 10).isActive = true
            pip.heightAnchor.constraint(equalToConstant: 10).isActive = true
            addArrangedSubview(pip)
        }
        isAccessibilityElement = true
        let learned = marks.filter { $0 }.count
        accessibilityLabel = "\(learned) of \(marks.count) sections learned"
    }

    required init(coder: NSCoder) { fatalError("init(coder:) is unavailable") }
}

@MainActor
func phraseAuthor(_ phrase: DancePhrase, store: AppStore) -> CreatorProfile {
    if phrase.authorID == "local-owner" {
        return CreatorProfile(
            id: "local-owner", name: store.library.profile.displayName,
            biography: store.library.profile.biography,
            avatarSymbol: store.library.profile.avatarSymbol, isLocalOwner: true)
    }
    return CreatorProfile(
        id: phrase.authorID, name: phrase.authorName,
        biography: "Sharing studio counts and practice notes.",
        avatarAsset: DancePhraseCatalog.portrait(for: phrase.authorID)
            ?? DancerPortraits.asset(forName: phrase.authorName))
}

@MainActor
func phraseAvatarImage(_ phrase: DancePhrase, store: AppStore) -> UIImage? {
    if phrase.authorID == "local-owner" { return store.ownerAvatarImage() }
    let asset = DancePhraseCatalog.portrait(for: phrase.authorID)
        ?? DancerPortraits.asset(forName: phrase.authorName)
    return UIImage(named: asset)
}
