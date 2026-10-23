import AVFoundation
import UIKit

final class PhraseDetailController: StackScreen {
    let phraseID: String
    private let pulse = PhrasePulse()
    private let lessonClock = PhraseLessonClock()
    private var lessonRate: Float = 1
    private var lessonMode: PhrasePlay = .all
    private var lessonSection = 0
    private var lessonStarted = false
    private var lessonNotice: String?
    private let film = PhraseFilm()
    private let header = UIView()
    private let modes = BubbleTrack(titles: ["Film", "Counts"], index: 0, barHeight: 36, lockedWidth: 196)
    private let stage = UIStackView()
    private let countsPane = UIStackView()
    private let practiceBar = UIStackView()
    private var shownEight = 0
    private var playing: PhrasePlay?
    private var clickFailed = false
    private var lastBeat: PhraseBeat?
    private var lineLabels: [UILabel] = []
    private var lineNumberLabels: [UILabel] = []
    private var pipEightIndices: [Int] = []
    private var lastTimedCue: Int?
    private var timeline: PhraseFilmTimeline?
    private var timelineSource: DancePhrase?
    private var reconfiguringTimeline = false
    private weak var filmPickupLabel: UILabel?
    private var lineRows: [UIView] = []
    private var pipButtons: [UIButton] = []
    private var pipWidths: [NSLayoutConstraint] = []
    private var previousEightButton: UIButton?
    private var nextEightButton: UIButton?
    private var learnedButton: StudioButton?
    private var keepButton: StudioButton?
    private var tempoButton: StudioButton?
    private var eightLabel: UILabel?
    private var pickupLabel: UILabel?
    private weak var countsScroller: UIScrollView?
    private var tempo: PhraseTempo?
    private var resignObserver: NSObjectProtocol?
    private var activeObserver: NSObjectProtocol?

    private enum PhrasePlay { case one, all }

    init(store: AppStore, phraseID: String) {
        self.phraseID = phraseID
        super.init(store: store, title: "Phrase")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

    override func build() {
        super.build()
        scroll.isHidden = true
        scroll.isUserInteractionEnabled = false
        header.translatesAutoresizingMaskIntoConstraints = false
        stage.axis = .horizontal
        stage.spacing = 8
        stage.distribution = .fillEqually
        stage.alignment = .fill
        stage.translatesAutoresizingMaskIntoConstraints = false
        practiceBar.axis = .vertical
        practiceBar.spacing = 12
        practiceBar.translatesAutoresizingMaskIntoConstraints = false
        modes.onSelect = { [weak self] index in
            guard let self else { return }
            if self.timeline == nil {
                if index == 0 { self.stopPulse(refreshing: false) } else { self.film.stop() }
            }
            self.refresh()
        }
        let modeBar = UIView()
        modeBar.translatesAutoresizingMaskIntoConstraints = false
        modes.translatesAutoresizingMaskIntoConstraints = false
        modeBar.addSubview(modes)
        view.addSubview(header)
        view.addSubview(modeBar)
        view.addSubview(stage)
        view.addSubview(practiceBar)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            modeBar.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            modeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            modeBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            modeBar.heightAnchor.constraint(equalToConstant: 36),
            modes.centerXAnchor.constraint(equalTo: modeBar.centerXAnchor),
            modes.topAnchor.constraint(equalTo: modeBar.topAnchor),
            modes.bottomAnchor.constraint(equalTo: modeBar.bottomAnchor),
            modes.widthAnchor.constraint(equalToConstant: 196),
            stage.topAnchor.constraint(equalTo: modeBar.bottomAnchor, constant: 12),
            stage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            practiceBar.topAnchor.constraint(equalTo: stage.bottomAnchor, constant: 12),
            practiceBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            practiceBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            practiceBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        resignObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.stopPulse(refreshing: false)
                self?.film.pause()
            }
        }
        activeObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.view.window != nil else { return }
                if self.timeline == nil, self.modes.index == 0 { self.startFilm() }
                self.refresh()
            }
        }
        lessonClock.prepare = { [weak self] time, range, rate, ready in
            guard let self else { ready(false); return }
            self.film.preparePractice(at: time, range: range, rate: rate, completion: ready)
        }
        lessonClock.onStart = { [weak self] time, rate, host in
            guard let self else { return }
            self.film.startPractice(at: time, rate: rate, hostTime: host)
            self.renderPracticeTime(time, force: true)
        }
        lessonClock.onTime = { [weak self] time in self?.renderPracticeTime(time) }
        lessonClock.onPickup = { [weak self] _ in
            guard let self else { return }
            self.renderPracticeTime(self.lessonClock.cueTime, force: true)
        }
        lessonClock.onClickFailed = { [weak self] in
            guard let self, !self.clickFailed else { return }
            self.clickFailed = true
            self.refresh()
        }
        lessonClock.onStopped = { [weak self] in
            self?.film.pause()
            self?.playing = nil
            self?.refresh()
        }
        lessonClock.onFailed = { [weak self] in self?.interruptLesson() }
        film.onPracticeInterrupted = { [weak self] in self?.interruptLesson() }
        film.onStopped = { [weak self] in
            self?.playing = nil
            self?.refresh()
        }
        pulse.onStopped = { [weak self] in
            self?.playing = nil
            self?.refresh()
        }
    }

    deinit {
        resignObserver.map { NotificationCenter.default.removeObserver($0) }
        activeObserver.map { NotificationCenter.default.removeObserver($0) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if modes.index == 0 { startFilm() }
        refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPulse(refreshing: false)
        film.pause()
    }

    override func refresh() {
        guard isViewLoaded else { return }
        guard let phrase = store.phrase(id: phraseID) else {
            if presentedViewController == nil, navigationController?.topViewController === self {
                navigationController?.popViewController(animated: true)
            }
            return
        }
        if timelineSource != phrase {
            reconfiguringTimeline = true
            timelineSource = phrase
            lessonClock.pause()
            film.pause()
            timeline = store.phraseTimeline(for: phrase)
            lessonRate = Float(phrase.lesson?.defaultRate ?? 1)
            lessonStarted = false
            playing = nil
            shownEight = 0
            lessonClock.position(at: 0)
            reconfiguringTimeline = false
        }
        if tempo == nil { tempo = phrase.tempo }
        if shownEight >= phrase.eights.count { shownEight = 0 }
        header.subviews.forEach { $0.removeFromSuperview() }
        stage.arrangedSubviews.forEach { $0.removeFromSuperview() }
        practiceBar.arrangedSubviews.forEach { $0.removeFromSuperview() }
        lineLabels = []
        lineNumberLabels = []
        pipEightIndices = []
        lineRows = []
        pipButtons = []
        pipWidths = []
        learnedButton = nil
        keepButton = nil
        eightLabel = nil
        pickupLabel = nil
        filmPickupLabel = nil
        countsScroller = nil
        title = phrase.title
        installStudioChrome()
        addHeader(phrase)
        addStage(phrase)
        addControls(phrase)
        syncEight(phrase)
        if timeline == nil, playing != nil, let lastBeat {
            apply(lastBeat, phrase: phrase)
        }
        if timeline != nil {
            renderPracticeTime(lessonClock.cueTime, force: true)
        } else if view.window != nil {
            if modes.index == 0 { startFilm() } else { film.stop() }
        }
    }

    private func addHeader(_ phrase: DancePhrase) {
        let portrait = roundPortrait(
            asset: DancePhraseCatalog.portrait(for: phrase.authorID),
            size: 56, personID: phrase.authorID,
            image: phrase.authorID == "local-owner" ? store.ownerAvatarImage() : nil)
        portrait.isUserInteractionEnabled = false
        let name = label(phrase.authorName, 18, title: true)
        name.numberOfLines = 1
        let style = label(phrase.style.title, 14, TetoTheme.muted)
        let words = stack([name, style], spacing: 2)
        words.isUserInteractionEnabled = false
        let author = UIButton(type: .custom)
        author.addSubview(portrait)
        author.addSubview(words)
        portrait.translatesAutoresizingMaskIntoConstraints = false
        words.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            portrait.leadingAnchor.constraint(equalTo: author.leadingAnchor),
            portrait.centerYAnchor.constraint(equalTo: author.centerYAnchor),
            words.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 10),
            words.trailingAnchor.constraint(equalTo: author.trailingAnchor),
            words.topAnchor.constraint(equalTo: author.topAnchor),
            words.bottomAnchor.constraint(equalTo: author.bottomAnchor),
            author.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
        ])
        author.accessibilityLabel = "Open \(phrase.authorName)'s profile"
        author.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.push(CreatorController(store: self.store, creator: phraseAuthor(phrase, store: self.store)))
        }, for: .touchUpInside)
        let marks = store.learnedMarks(for: phrase.id)
        let learnedOn = marks.indices.contains(shownEight) && marks[shownEight]
        let learned = actionButton(
            "Learned", icon: learnedOn ? .check : .checkbox, tone: learnedOn ? .lime : .quiet,
            compact: true, iconSize: 18
        ) { [weak self] in self?.toggleLearned() }
        learned.accessibilityValue = learnedOn ? "Marked" : "Not marked"
        learnedButton = learned
        let kept = store.isPhraseKept(phrase.id)
        let keep = actionButton(
            kept ? "Kept" : "Keep", icon: kept ? .starFill : .star, tone: kept ? .lime : .quiet,
            compact: true, iconSize: 18
        ) { [weak self] in self?.toggleKeep() }
        keepButton = keep
        for button in [learned, keep] {
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
            button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            button.caption.adjustsFontSizeToFitWidth = true
            button.caption.minimumScaleFactor = 0.7
        }
        let side = stack([learned, keep], spacing: 6)
        side.widthAnchor.constraint(equalToConstant: 108).isActive = true
        side.alignment = .fill
        let row = stack([author, side], axis: .horizontal, spacing: 12)
        row.alignment = .center
        author.setContentHuggingPriority(.defaultLow, for: .horizontal)
        side.setContentHuggingPriority(.required, for: .horizontal)
        header.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            row.topAnchor.constraint(equalTo: header.topAnchor),
            row.bottomAnchor.constraint(equalTo: header.bottomAnchor),
        ])
    }

    private func addStage(_ phrase: DancePhrase) {
        if modes.index == 0 {
            stage.addArrangedSubview(filmPane(phrase))
            return
        }
        stage.addArrangedSubview(countsPaneView(phrase))
    }

    private func filmPane(_ phrase: DancePhrase) -> UIView {
        let host = UIView()
        host.backgroundColor = .black
        host.layer.cornerRadius = 18
        host.layer.cornerCurve = .continuous
        host.clipsToBounds = true
        film.view.translatesAutoresizingMaskIntoConstraints = false
        film.view.isUserInteractionEnabled = false
        host.addSubview(film.view)
        film.view.pin(to: host)
        if timeline != nil {
            let pickup = label("", 72, .white, title: true)
            pickup.textAlignment = .center
            pickup.backgroundColor = UIColor.black.withAlphaComponent(0.55)
            pickup.layer.cornerRadius = 20
            pickup.clipsToBounds = true
            pickup.isHidden = true
            host.addSubview(pickup)
            pickup.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pickup.centerXAnchor.constraint(equalTo: host.centerXAnchor),
                pickup.centerYAnchor.constraint(equalTo: host.centerYAnchor),
                pickup.widthAnchor.constraint(equalToConstant: 112),
                pickup.heightAnchor.constraint(equalToConstant: 112),
            ])
            filmPickupLabel = pickup
        }
        if filmURL(for: phrase) == nil {
            let note = label("No dance video for this phrase.", 15, .white)
            note.textAlignment = .center
            host.addSubview(note)
            note.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                note.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 16),
                note.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -16),
                note.centerYAnchor.constraint(equalTo: host.centerYAnchor),
            ])
        }
        return host
    }

    private func filmEntry(for phrase: DancePhrase) -> DanceVideo? {
        var current: String? = phrase.id
        var steps = 0
        while let id = current, steps < 6 {
            if let name = DancePhraseCatalog.filmAsset[id],
                let entry = DanceVideoCatalog.entries.first(where: { $0.assetName == name })
            {
                return entry
            }
            let parent = store.phraseRecord(id: id)?.parentID
            if parent == id { return nil }
            current = parent
            steps += 1
        }
        return nil
    }

    private func filmURL(for phrase: DancePhrase) -> URL? {
        store.phraseVideoURL(for: phrase)
    }

    private func startFilm() {
        guard let phrase = store.phrase(id: phraseID),
              let url = filmURL(for: phrase), film.prepare(url)
        else { return }
        if timeline != nil {
            guard !lessonStarted else { return }
            beginLesson(phrase.lesson?.startsWithLoop == true ? .one : .all, from: 0)
            refresh()
        } else {
            if let duration = filmEntry(for: phrase)?.duration { film.play(range: 0...duration, loop: true) }
        }
    }

    private func renderPracticeTime(_ time: TimeInterval, force: Bool = false) {
        guard !reconfiguringTimeline, let timeline, let phrase = store.phrase(id: phraseID),
              let index = timeline.cueIndex(at: min(time, timeline.duration - 0.001))
        else { return }
        let cue = timeline.cues[index]
        let activePosition = timeline.actionIndexByCue[index].flatMap { timeline.position(of: $0) }
        if let actionIndex = timeline.actionIndexByCue[index], let position = timeline.position(of: actionIndex), position.section != shownEight {
            shownEight = position.section
            lastTimedCue = nil
            refresh()
            return
        }
        pickupLabel?.isHidden = false
        filmPickupLabel?.text = lessonClock.pickup.map(String.init)
        filmPickupLabel?.isHidden = lessonClock.pickup == nil
        pickupLabel?.font = TetoTheme.font(lessonClock.pickup == nil ? 14 : 28, title: true)
        let timeText = PhraseFilmTimeline.timestamp(time)
        if let pickup = lessonClock.pickup {
            pickupLabel?.text = "Get ready · \(pickup)"
        } else if lessonClock.isPreparing {
            pickupLabel?.text = "Getting ready"
        } else {
            pickupLabel?.text = cue.isAction ? "Count \((activePosition?.offset ?? 0) + 1) · \(rateTitle)" : "\(timeText) · Instruction\n\(cue.text)"
        }
        guard modes.index == 1 else { return }
        guard force || lastTimedCue != index else { return }
        lastTimedCue = index
        syncEight(phrase)
        let actionIndex = timeline.actionIndexByCue[index]
        for (offset, row) in lineRows.enumerated() {
            row.backgroundColor = !lessonClock.isPreparing && actionIndex != nil && actionIndex == timeline.actionIndex(section: shownEight, offset: offset) ? TetoTheme.lime : .clear
        }
        if let actionIndex, let position = timeline.position(of: actionIndex) { revealCount(position.offset) }
    }

    private func countsPaneView(_ phrase: DancePhrase) -> UIView {
        let right = UIView()
        right.backgroundColor = UIColor.white.withAlphaComponent(0.94)
        right.layer.cornerRadius = 18
        right.layer.cornerCurve = .continuous
        right.clipsToBounds = true
        let previous = iconButton(.back, "Previous section") { [weak self] in self?.stepEight(-1) }
        let next = iconButton(.forward, "Next section") { [weak self] in self?.stepEight(1) }
        previousEightButton = previous
        nextEightButton = next
        let heading = label("Section \(shownEight + 1) of \(phrase.eights.count)", 15, title: true)
        heading.textAlignment = .center
        heading.adjustsFontSizeToFitWidth = true
        heading.minimumScaleFactor = 0.7
        eightLabel = heading
        let switcher = stack([previous, heading, next], axis: .horizontal, spacing: 4)
        switcher.alignment = .center
        let pips = stack(axis: .horizontal, spacing: 4)
        pips.alignment = .center
        pips.distribution = .fill
        let firstPip = max(0, min(shownEight - 4, phrase.eights.count - 9))
        for index in firstPip..<min(firstPip + 9, phrase.eights.count) {
            let pip = UIButton(type: .custom)
            pip.translatesAutoresizingMaskIntoConstraints = false
            let width = pip.widthAnchor.constraint(equalToConstant: index == shownEight ? 28 : 10)
            width.isActive = true
            pip.heightAnchor.constraint(equalToConstant: 10).isActive = true
            pip.layer.cornerRadius = 5
            pip.layer.borderColor = TetoTheme.emerald.cgColor
            pip.setContentHuggingPriority(.required, for: .horizontal)
            pip.setContentCompressionResistancePriority(.required, for: .horizontal)
            pip.accessibilityLabel = "Section \(index + 1)"
            pip.addAction(UIAction { [weak self] _ in self?.show(eight: index, stopClick: true) }, for: .touchUpInside)
            pips.addArrangedSubview(pip)
            pipEightIndices.append(index)
            pipButtons.append(pip)
            pipWidths.append(width)
        }
        let pickup = label("", timeline == nil ? 28 : 14, TetoTheme.emerald, title: true)
        pickup.numberOfLines = 2
        pickup.textAlignment = .center
        pickup.isHidden = true
        pickupLabel = pickup
        countsPane.axis = .vertical
        countsPane.spacing = 2
        countsPane.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let eight = phrase.eights[shownEight]
        for offset in 0..<8 {
            let text = eight.indices.contains(offset) ? eight[offset] : ""
            let number = label("\(offset + 1)", timeline == nil ? 18 : 12, TetoTheme.emerald, title: true)
            number.numberOfLines = 2
            lineNumberLabels.append(number)
            number.setContentHuggingPriority(.required, for: .horizontal)
            let count = label(text, 20)
            count.numberOfLines = 2
            lineLabels.append(count)
            let line = stack([number, count], axis: .horizontal, spacing: 8)
            line.alignment = .center
            line.isLayoutMarginsRelativeArrangement = true
            line.layoutMargins = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
            line.layer.cornerRadius = 10
            lineRows.append(line)
            countsPane.addArrangedSubview(line)
        }
        let scroller = UIScrollView()
        countsScroller = scroller
        scroller.showsVerticalScrollIndicator = false
        scroller.addSubview(countsPane)
        countsPane.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countsPane.leadingAnchor.constraint(equalTo: scroller.contentLayoutGuide.leadingAnchor),
            countsPane.trailingAnchor.constraint(equalTo: scroller.contentLayoutGuide.trailingAnchor),
            countsPane.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
            countsPane.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor),
            countsPane.widthAnchor.constraint(equalTo: scroller.frameLayoutGuide.widthAnchor),
        ])
        let pipRow = stack([pips], spacing: 0)
        pipRow.alignment = .center
        let column = stack([switcher, pipRow, pickup, scroller], spacing: 6)
        right.addSubview(column)
        column.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            column.leadingAnchor.constraint(equalTo: right.leadingAnchor, constant: 6),
            column.trailingAnchor.constraint(equalTo: right.trailingAnchor, constant: -6),
            column.topAnchor.constraint(equalTo: right.topAnchor, constant: 8),
            column.bottomAnchor.constraint(equalTo: right.bottomAnchor, constant: -8),
        ])
        return right
    }

    private func addControls(_ phrase: DancePhrase) {
        let speed = tempo ?? phrase.tempo
        let count = phrase.eights[shownEight].count
        let loopTitle = timeline == nil ? "This section" : "Loop \(count) counts"
        let thisEight = thirdButton(
            playing == .one ? (timeline == nil ? "Stop" : "Pause") : loopTitle,
            icon: playing == .one ? .pause : .play, primary: playing != .all
        ) { [weak self] in self?.start(.one) }
        let fromStart = thirdButton(
            playing == .all ? (timeline == nil ? "Stop" : "Pause") : (timeline == nil ? "From the start" : "Whole lesson"),
            icon: playing == .all ? .pause : .play, primary: false
        ) { [weak self] in self?.start(.all) }
        let speedButton = thirdButton(timeline == nil ? speed.title : rateTitle, icon: .clock, primary: false) { [weak self] in
            self?.cycleTempo()
        }
        tempoButton = speedButton
        let showingControls = timeline != nil || modes.index != 0
        if showingControls {
            if timeline != nil, modes.index == 0 {
                let previous = iconButton(.back, "Previous section") { [weak self] in self?.stepEight(-1) }
                let next = iconButton(.forward, "Next section") { [weak self] in self?.stepEight(1) }
                previousEightButton = previous
                nextEightButton = next
                let title = label("Section \(shownEight + 1) of \(phrase.eights.count)", 14, title: true)
                title.textAlignment = .center
                eightLabel = title
                let status = label("", 13, TetoTheme.emerald)
                status.numberOfLines = 2
                status.textAlignment = .center
                pickupLabel = status
                let heading = stack([title, status], spacing: 2)
                let row = stack([previous, heading, next], axis: .horizontal, spacing: 8)
                row.alignment = .center
                practiceBar.addArrangedSubview(row)
            }
            let first = stack([thisEight, fromStart, speedButton], axis: .horizontal, spacing: 8)
            first.distribution = .fillEqually
            practiceBar.addArrangedSubview(first)
        }
        let rewrite: StudioButton
        if phrase.authorID == "local-owner" {
            rewrite = thirdButton("Edit", icon: .check, primary: false) { [weak self] in
                guard let self, let phrase = self.store.phraseRecord(id: self.phraseID) else { return }
                self.push(PhraseEditorController(store: self.store, mode: .edit(phrase)))
            }
        } else {
            rewrite = thirdButton("Branch", icon: .plus, primary: false) { [weak self] in
                guard let self, let phrase = self.store.phrase(id: self.phraseID) else { return }
                self.push(PhraseEditorController(store: self.store, mode: .branch(phrase)))
            }
        }
        let more = thirdButton("More", icon: .more, primary: false) { [weak self] in self?.showMore() }
        let share = thirdButton("Share", icon: .share, primary: false) { [weak self] in self?.showShare() }
        let second = stack([rewrite, more, share], axis: .horizontal, spacing: 8)
        second.distribution = .fillEqually
        practiceBar.addArrangedSubview(second)
        if showingControls, let first = practiceBar.arrangedSubviews.first {
            practiceBar.setCustomSpacing(24, after: first)
        }
        if let lessonNotice {
            practiceBar.addArrangedSubview(label(lessonNotice, 13, TetoTheme.muted))
        }
        if clickFailed {
            practiceBar.addArrangedSubview(label("The click could not start.", 13, TetoTheme.muted))
        }
        if let parent = phrase.parentTitle {
            let from: UIView
            if store.phrase(id: phrase.parentID ?? "") != nil {
                from = actionButton("From \(parent)", icon: .forward, compact: true, iconSize: 18) {
                    [weak self] in self?.openParent(phrase)
                }
            } else {
                let line = label("From \(parent)", 13, TetoTheme.muted)
                line.accessibilityLabel = "From \(parent). The original phrase is not on this device."
                from = line
            }
            practiceBar.addArrangedSubview(from)
        }
    }

    private func thirdButton(
        _ title: String, icon: TetoIcon, primary: Bool, action: @escaping () -> Void
    ) -> StudioButton {
        let button = actionButton(title, icon: icon, primary: primary, compact: true, iconSize: 26, action: action)
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        button.caption.adjustsFontSizeToFitWidth = true
        button.caption.minimumScaleFactor = 0.6
        button.caption.textAlignment = .center
        button.caption.numberOfLines = 2
        return button
    }

    private var rateTitle: String {
        lessonRate == 0.5 ? "0.5x" : (lessonRate == 0.75 ? "0.75x" : "1x")
    }

    private func cycleTempo() {
        if timeline != nil {
            lessonRate = lessonRate == 1 ? 0.5 : (lessonRate == 0.5 ? 0.75 : 1)
            if let mode = playing { beginLesson(mode, from: lessonClock.currentTime) }
            refresh()
            return
        }
        let order = PhraseTempo.allCases
        let current = tempo ?? .slow
        let next = order[((order.firstIndex(of: current) ?? 0) + 1) % order.count]
        tempo = next
        let mode = playing
        stopPulse(refreshing: false)
        refresh()
        if let mode { start(mode) }
    }

    private func start(_ mode: PhrasePlay) {
        guard let phrase = store.phrase(id: phraseID) else { return }
        if timeline != nil {
            if playing == mode {
                stopPulse(refreshing: false)
                film.pause()
            } else {
                let position = lessonStarted && lessonMode == mode ? lessonClock.currentTime : nil
                beginLesson(mode, from: position)
            }
            refresh()
            return
        }
        if playing == mode {
            stopPulse()
            return
        }
        stopPulse(refreshing: false)
        playing = mode
        clickFailed = false
        let startEight = mode == .one ? shownEight : 0
        if mode == .all { shownEight = 0 }
        pulse.play(
            tempo: tempo ?? phrase.tempo, groupSizes: phrase.eights.map(\.count), startEight: startEight,
            loopOneEight: mode == .one,
            onBeat: { [weak self] beat in self?.apply(beat) },
            onClickFailed: { [weak self] in
                guard let self, !self.clickFailed else { return }
                self.clickFailed = true
                self.refresh()
            }
        )
        refresh()
    }

    private func beginLesson(_ mode: PhrasePlay, from position: TimeInterval? = nil) {
        guard let timeline, let phrase = store.phrase(id: phraseID),
              let url = filmURL(for: phrase), film.prepare(url) else { return }
        if mode == .one, position == nil || lessonMode != .one { lessonSection = shownEight }
        let ranges = mode == .one ? timeline.practiceRanges(for: lessonSection) : [0...timeline.duration]
        guard let first = ranges.first else { return }
        lessonClock.pause()
        film.pause()
        lessonStarted = true
        lessonMode = mode
        playing = mode
        lessonNotice = nil
        lastTimedCue = nil
        clickFailed = false
        lessonClock.play(ranges: ranges, rate: lessonRate, loop: mode == .one,
                         from: position ?? first.lowerBound,
                         pickupBeatDuration: phrase.lesson.map { 60 / Double($0.pickupBPM) } ?? phrase.tempo.beatDuration)
    }

    private func interruptLesson() {
        stopPulse(refreshing: false)
        film.pause()
        lessonNotice = "Video paused. Tap a practice button to try again."
        refresh()
    }

    private func stopPulse(refreshing: Bool = true) {
        let wasPlaying = playing != nil || pulse.isPlaying
        playing = nil
        lessonClock.pause()
        pulse.stop()
        pickupLabel?.isHidden = true
        if refreshing && wasPlaying { refresh() }
    }

    private func apply(_ beat: PhraseBeat) {
        guard let phrase = store.phrase(id: phraseID) else { return }
        apply(beat, phrase: phrase)
    }

    private func apply(_ beat: PhraseBeat, phrase: DancePhrase) {
        lastBeat = beat
        if beat.eightIndex != shownEight, phrase.eights.indices.contains(beat.eightIndex) {
            shownEight = beat.eightIndex
            refresh()
            return
        }
        syncEight(phrase)
        pickupLabel?.isHidden = beat.pickup == nil
        pickupLabel?.text = beat.pickup.map(String.init) ?? ""
        for (offset, row) in lineRows.enumerated() {
            row.backgroundColor = beat.pickup == nil && beat.count == offset + 1 ? TetoTheme.lime : .clear
        }
        if beat.pickup == nil { revealCount(beat.count - 1) }
    }

    private func revealCount(_ index: Int) {
        guard let scroller = countsScroller, lineRows.indices.contains(index) else { return }
        scroller.layoutIfNeeded()
        scroller.scrollRectToVisible(lineRows[index].convert(lineRows[index].bounds, to: countsPane), animated: false)
    }

    private func syncEight(_ phrase: DancePhrase) {
        eightLabel?.text = "Section \(shownEight + 1) of \(phrase.eights.count)"
        let lines = phrase.eights[shownEight]
        for (offset, line) in lineLabels.enumerated() {
            let exists = lines.indices.contains(offset)
            line.text = exists ? lines[offset] : ""
            lineRows[offset].isHidden = !exists
            if let actionIndex = timeline?.actionIndex(section: shownEight, offset: offset), let cue = timeline?.action(actionIndex) {
                lineNumberLabels[offset].text = "\(offset + 1)\n\(PhraseFilmTimeline.timestamp(cue.start))"
            } else {
                lineNumberLabels[offset].text = "\(offset + 1)"
            }
        }
        for (offset, pip) in pipButtons.enumerated() {
            let selected = pipEightIndices[offset] == shownEight
            if pipWidths.indices.contains(offset) { pipWidths[offset].constant = selected ? 28 : 10 }
            pip.layer.cornerRadius = 5
            pip.backgroundColor = selected ? TetoTheme.emerald : .white
            pip.layer.borderWidth = selected ? 0 : 1
        }
        let marks = store.learnedMarks(for: phrase.id)
        let learnedOn = marks.indices.contains(shownEight) && marks[shownEight]
        paint(learnedButton, title: "Learned", on: learnedOn)
        learnedButton?.iconView.image = (learnedOn ? TetoIcon.check : .checkbox).image(TetoTheme.emerald, size: 18)
        learnedButton?.accessibilityValue = learnedOn ? "Marked" : "Not marked"
        let kept = store.isPhraseKept(phrase.id)
        paint(keepButton, title: kept ? "Kept" : "Keep", on: kept)
        keepButton?.iconView.image = (kept ? TetoIcon.starFill : .star).image(TetoTheme.emerald, size: 18)
        tempoButton?.caption.text = timeline == nil ? (tempo ?? phrase.tempo).title : rateTitle
        tempoButton?.accessibilityLabel = timeline == nil ? (tempo ?? phrase.tempo).title : "Practice speed \(rateTitle)"
        let hasPrevious = shownEight > 0
        let hasNext = shownEight < phrase.eights.count - 1
        previousEightButton?.isEnabled = hasPrevious
        nextEightButton?.isEnabled = hasNext
        previousEightButton?.alpha = hasPrevious ? 1 : 0.35
        nextEightButton?.alpha = hasNext ? 1 : 0.35
    }

    private func paint(_ button: StudioButton?, title: String, on: Bool) {
        button?.caption.text = title
        button?.caption.textColor = TetoTheme.ink
        button?.backgroundColor = on ? TetoTheme.lime : UIColor.white.withAlphaComponent(0.86)
        button?.layer.borderWidth = on ? 0 : 1
        button?.layer.borderColor = TetoTheme.line.cgColor
        button?.accessibilityLabel = title
    }

    private func stepEight(_ delta: Int) {
        guard let phrase = store.phrase(id: phraseID) else { return }
        let next = shownEight + delta
        guard phrase.eights.indices.contains(next) else { return }
        show(eight: next, stopClick: true)
    }

    private func show(eight index: Int, stopClick: Bool) {
        if let timeline, let range = timeline.practiceRanges(for: index).first,
           let phrase = store.phrase(id: phraseID), let url = filmURL(for: phrase), film.prepare(url) {
            let resume = playing != nil
            stopPulse(refreshing: false)
            film.pause()
            shownEight = index
            lessonSection = index
            lessonMode = .one
            lessonStarted = true
            lastTimedCue = nil
            lessonClock.position(at: range.lowerBound)
            if resume { beginLesson(.one, from: range.lowerBound) }
            else { film.seek(to: range.lowerBound, resume: false) }
            refresh()
            return
        }
        if stopClick { stopPulse(refreshing: false) }
        shownEight = index
        lastBeat = nil
        refresh()
    }

    private func toggleLearned() {
        let index = shownEight
        Task { [weak self] in
            guard let self else { return }
            if await self.store.toggleLearned(id: self.phraseID, eightIndex: index) == false {
                self.message(self.store.lastSaveError ?? "Your changes could not be saved. Please try again.")
            }
        }
    }

    private func toggleKeep() {
        Task { [weak self] in
            guard let self else { return }
            if await self.store.toggleKept(id: self.phraseID) == false {
                self.message(self.store.lastSaveError ?? "Your changes could not be saved. Please try again.")
            }
        }
    }

    private func openParent(_ phrase: DancePhrase) {
        guard let parentID = phrase.parentID, store.phrase(id: parentID) != nil else { return }
        push(PhraseDetailController(store: store, phraseID: parentID))
    }

    private func showMore() {
        guard let phrase = store.phrase(id: phraseID) else { return }
        var lines: [UIView] = [label(phrase.title, 22, title: true)]
        if phrase.authorID == "local-owner" {
            lines.append(actionButton("Delete phrase", icon: .trash, tone: .danger) { [weak self] in
                self?.dismissCard { self?.confirmDelete() }
            })
        } else {
            lines.append(actionButton("Report phrase", icon: .flag) { [weak self] in
                self?.dismissCard { self?.report() }
            })
            lines.append(actionButton("Block dancer", icon: .block, tone: .danger) { [weak self] in
                self?.dismissCard { self?.block() }
            })
        }
        if let credit = phrase.lesson?.credits ?? filmEntry(for: phrase).flatMap({ DancePhraseCatalog.filmCredits[$0.assetName] }) {
            lines.append(actionButton("Film credits", icon: .info) { [weak self] in
                self?.dismissCard { self?.showFilmCredits(credit) }
            })
        }
        showCard(lines)
    }

    private func showFilmCredits(_ credit: String) {
        let screen = TetoScreen(store: store, title: "Film credits")
        let text = UITextView()
        text.isEditable = false
        text.isSelectable = true
        text.dataDetectorTypes = [.link]
        text.backgroundColor = .clear
        text.font = TetoTheme.font(16)
        text.adjustsFontForContentSizeCategory = true
        text.textColor = TetoTheme.ink
        text.linkTextAttributes = [.foregroundColor: TetoTheme.emerald]
        text.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        text.text = credit
        text.translatesAutoresizingMaskIntoConstraints = false
        screen.view.addSubview(text)
        NSLayoutConstraint.activate([
            text.leadingAnchor.constraint(equalTo: screen.view.safeAreaLayoutGuide.leadingAnchor),
            text.trailingAnchor.constraint(equalTo: screen.view.safeAreaLayoutGuide.trailingAnchor),
            text.topAnchor.constraint(equalTo: screen.view.safeAreaLayoutGuide.topAnchor),
            text.bottomAnchor.constraint(equalTo: screen.view.safeAreaLayoutGuide.bottomAnchor),
        ])
        navigationController?.pushViewController(screen, animated: true)
    }

    private func confirmDelete() {
        confirm(
            "Delete this phrase?",
            message: "This removes the phrase from this device. Phrases that grew from it keep their own counts.",
            destructive: true, button: "Delete"
        ) { [weak self] in
            guard let self else { return }
            Task {
                if await self.store.deletePhrase(id: self.phraseID) == false {
                    self.message(self.store.lastSaveError ?? "This phrase could not be saved. Please try again.")
                }
            }
        }
    }

    private func report() {
        guard let phrase = store.phrase(id: phraseID) else { return }
        let safety = SafetyController(
            store: store,
            target: .phrase(
                id: phrase.id, title: phrase.title, authorID: phrase.authorID, authorName: phrase.authorName),
            reporting: true)
        safety.onResolved = { [weak self] in self?.refresh() }
        presentScreen(safety)
    }

    private func block() {
        guard let phrase = store.phrase(id: phraseID) else { return }
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

    private func showShare() {
        guard let phrase = store.phrase(id: phraseID) else { return }
        let title = label("Share with", 22, title: true)
        let close = iconButton(.close, "Close") { [weak self] in self?.dismissCard() }
        let headerRow = stack([title, UIView(), close], axis: .horizontal, spacing: 8)
        headerRow.alignment = .center
        let people = store.chatConversations.filter {
            $0.kind == .person && $0.creator?.isLocalOwner != true && store.followsChatPartner($0)
        }
        let scroller = UIScrollView()
        scroller.showsHorizontalScrollIndicator = false
        scroller.translatesAutoresizingMaskIntoConstraints = false
        scroller.heightAnchor.constraint(equalToConstant: 96).isActive = true
        if people.isEmpty {
            let empty = label("Add a friend in Chats before sharing with someone.", 14, TetoTheme.muted)
            scroller.addSubview(empty)
            empty.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                empty.leadingAnchor.constraint(equalTo: scroller.contentLayoutGuide.leadingAnchor),
                empty.trailingAnchor.constraint(equalTo: scroller.contentLayoutGuide.trailingAnchor),
                empty.centerYAnchor.constraint(equalTo: scroller.frameLayoutGuide.centerYAnchor),
                empty.widthAnchor.constraint(equalTo: scroller.frameLayoutGuide.widthAnchor),
            ])
        } else {
            let row = stack(axis: .horizontal, spacing: 14)
            scroller.addSubview(row)
            row.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: scroller.contentLayoutGuide.leadingAnchor),
                row.trailingAnchor.constraint(equalTo: scroller.contentLayoutGuide.trailingAnchor),
                row.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
                row.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor),
                row.heightAnchor.constraint(equalTo: scroller.frameLayoutGuide.heightAnchor),
            ])
            for person in people {
                row.addArrangedSubview(sharePerson(person, phrase: phrase))
            }
        }
        showBottomPanel(stack([headerRow, scroller, linkAction(phrase)], spacing: 16))
    }

    private func sharePerson(_ person: DanceConversation, phrase: DancePhrase) -> UIView {
        let item = UIButton(type: .custom)
        let photo = conversationPortrait(person, size: 56)
        let nickname = person.name.components(separatedBy: " ").first ?? person.name
        let name = label(nickname, 12)
        name.textAlignment = .center
        name.isAccessibilityElement = false
        let column = stack([photo, name], spacing: 6)
        column.alignment = .center
        column.isUserInteractionEnabled = false
        item.addSubview(column)
        column.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            item.widthAnchor.constraint(equalToConstant: 68),
            column.topAnchor.constraint(equalTo: item.topAnchor),
            column.bottomAnchor.constraint(equalTo: item.bottomAnchor),
            column.centerXAnchor.constraint(equalTo: item.centerXAnchor),
        ])
        item.accessibilityLabel = person.name
        item.addAction(UIAction { [weak self] _ in self?.share(phrase, with: person) }, for: .touchUpInside)
        return item
    }

    private func linkAction(_ phrase: DancePhrase) -> UIView {
        actionButton("Share link", icon: .share) { [weak self] in
            UIPasteboard.general.string = "teto://phrase/\(phrase.id)"
            self?.dismissCard {
                self?.message("Link copied. This address stays inside Teto and is not a public web page.")
            }
        }
    }

    private func share(_ phrase: DancePhrase, with person: DanceConversation) {
        let text = "Practice this phrase: \(phrase.title). Address: teto://phrase/\(phrase.id)"
        dismissCard { [weak self] in
            guard let self else { return }
            Task {
                if await self.store.sendChatMessage(text, to: person) {
                    self.message("Saved in your chat with \(person.name). It stays on this device.")
                } else {
                    self.message(self.store.lastSaveError ?? "That message could not be saved.")
                }
            }
        }
    }
}

@MainActor
private final class PhraseFilm {
    let view = VideoLayerView()
    var onStopped: (() -> Void)?
    var onPracticeInterrupted: (() -> Void)?
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?
    private var stallObserver: NSObjectProtocol?
    private var failureObserver: NSObjectProtocol?
    private var readyObserver: NSKeyValueObservation?
    private var preparationTimeout: DispatchWorkItem?
    private var preparationCompletion: ((Bool) -> Void)?
    private var followingPractice = false
    private var playingURL: URL?
    private var playbackRange: ClosedRange<TimeInterval>?
    private var loops = true
    private var seekGeneration = 0
    private var seekTarget: TimeInterval?
    private var idleDisabled = false
    private(set) var isPlaying = false

    var currentTime: TimeInterval {
        if let seekTarget { return seekTarget }
        let seconds = player?.currentTime().seconds ?? 0
        return seconds.isFinite ? max(0, seconds) : 0
    }

    @discardableResult
    func prepare(_ url: URL) -> Bool {
        if playingURL == url, let player, player.status != .failed,
           let item = player.currentItem, item.status != .failed { return true }
        stop()
        guard FileManager.default.fileExists(atPath: url.path) else { return false }
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.isMuted = false
        view.videoLayer.videoGravity = .resizeAspectFill
        view.videoLayer.player = player
        self.player = player
        playingURL = url
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.03, preferredTimescale: 600), queue: .main
        ) { [weak self] time in
            MainActor.assumeIsolated { self?.tick(time.seconds) }
        }
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.reachedEnd() }
        }
        stallObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemPlaybackStalled, object: item, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.followingPractice, self.isPlaying else { return }
                self.onPracticeInterrupted?()
            }
        }
        failureObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.followingPractice else { return }
                self.onPracticeInterrupted?()
            }
        }
        return true
    }

    /// Prepare a clock-selected source range without advancing the lesson clock.
    func preparePractice(
        at time: TimeInterval, range: ClosedRange<TimeInterval>, rate: Float,
        completion: @escaping (Bool) -> Void
    ) {
        pause()
        guard let player, let item = player.currentItem else { completion(false); return }
        followingPractice = true
        player.automaticallyWaitsToMinimizeStalling = false
        item.audioTimePitchAlgorithm = .timeDomain
        item.forwardPlaybackEndTime = CMTime(seconds: range.upperBound, preferredTimescale: 600)
        seekTarget = time
        preparationCompletion = completion
        let request = seekGeneration
        let timeout = DispatchWorkItem { [weak self] in
            guard let self, self.seekGeneration == request else { return }
            self.finishPreparation(false)
        }
        preparationTimeout = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: timeout)
        readyObserver = player.observe(\.status, options: [.initial, .new]) { [weak self] player, _ in
            let status = player.status
            Task { @MainActor [weak self] in
                guard let self, self.seekGeneration == request, self.preparationCompletion != nil else { return }
                if status == .failed {
                    self.finishPreparation(false)
                } else if status == .readyToPlay, self.readyObserver != nil {
                    self.readyObserver = nil
                    self.primePractice(at: time, rate: rate, request: request)
                }
            }
        }
    }

    private func primePractice(at time: TimeInterval, rate: Float, request: Int) {
        guard let player, player.status == .readyToPlay else { finishPreparation(false); return }
        if rate < 1, player.currentItem?.canPlaySlowForward != true {
            finishPreparation(false)
            return
        }
        player.seek(to: CMTime(seconds: time, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) {
            [weak self] finished in
            Task { @MainActor [weak self] in
                guard let self, self.seekGeneration == request, let player = self.player else { return }
                guard finished, player.status == .readyToPlay else { self.finishPreparation(false); return }
                player.preroll(atRate: rate) { [weak self] ready in
                    Task { @MainActor [weak self] in
                        guard let self, self.seekGeneration == request else { return }
                        self.finishPreparation(ready)
                    }
                }
            }
        }
    }

    private func finishPreparation(_ ready: Bool) {
        readyObserver = nil
        preparationTimeout?.cancel()
        preparationTimeout = nil
        let completion = preparationCompletion
        preparationCompletion = nil
        seekTarget = nil
        completion?(ready)
    }

    func startPractice(at time: TimeInterval, rate: Float, hostTime: TimeInterval) {
        guard followingPractice, let player, player.status == .readyToPlay else {
            onPracticeInterrupted?()
            return
        }
        isPlaying = true
        preventIdle(true)
        player.setRate(rate, time: CMTime(seconds: time, preferredTimescale: 600),
                       atHostTime: CMTime(seconds: hostTime, preferredTimescale: 1_000_000_000))
    }

    func play(from time: TimeInterval? = nil, range: ClosedRange<TimeInterval>, loop: Bool) {
        guard player != nil else { return }
        followingPractice = false
        player?.automaticallyWaitsToMinimizeStalling = true
        player?.currentItem?.forwardPlaybackEndTime = .invalid
        playbackRange = range
        loops = loop
        let target = time ?? currentTime
        if let time {
            seek(to: min(max(time, range.lowerBound), range.upperBound), resume: true)
        } else if target < range.lowerBound || target >= range.upperBound - 0.01 {
            seek(to: range.lowerBound, resume: true)
        } else {
            isPlaying = true
            preventIdle(true)
            player?.play()
        }
    }

    func seek(to time: TimeInterval, resume: Bool) {
        guard let player else { return }
        seekGeneration += 1
        let generation = seekGeneration
        let target = max(0, time)
        seekTarget = target
        player.pause()
        isPlaying = resume
        preventIdle(resume)
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) {
            [weak self] finished in
            Task { @MainActor [weak self] in
                guard let self, generation == self.seekGeneration else { return }
                self.seekTarget = nil
                guard finished else {
                    self.pause()
                    self.onStopped?()
                    return
                }
                if resume, self.isPlaying { self.player?.play() }
            }
        }
    }

    func pause() {
        seekGeneration += 1
        readyObserver = nil
        preparationTimeout?.cancel()
        preparationTimeout = nil
        preparationCompletion = nil
        player?.cancelPendingPrerolls()
        player?.currentItem?.cancelPendingSeeks()
        seekTarget = nil
        player?.pause()
        isPlaying = false
        preventIdle(false)
    }

    private func preventIdle(_ enabled: Bool) {
        if enabled {
            UIApplication.shared.isIdleTimerDisabled = true
            idleDisabled = true
        } else if idleDisabled {
            UIApplication.shared.isIdleTimerDisabled = false
            idleDisabled = false
        }
    }

    private func tick(_ seconds: TimeInterval) {
        guard !followingPractice, seconds.isFinite, seekTarget == nil else { return }
        if isPlaying, let range = playbackRange, seconds >= range.upperBound {
            reachedEnd()
            return
        }
    }

    private func reachedEnd() {
        guard !followingPractice, isPlaying, seekTarget == nil, let range = playbackRange else { return }
        if loops {
            seek(to: range.lowerBound, resume: true)
        } else {
            pause()
            onStopped?()
        }
    }

    func stop() {
        pause()
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        timeObserver = nil
        endObserver.map { NotificationCenter.default.removeObserver($0) }
        endObserver = nil
        stallObserver.map { NotificationCenter.default.removeObserver($0) }
        stallObserver = nil
        failureObserver.map { NotificationCenter.default.removeObserver($0) }
        failureObserver = nil
        view.videoLayer.player = nil
        player = nil
        playingURL = nil
        playbackRange = nil
        followingPractice = false
    }

    deinit {
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        endObserver.map { NotificationCenter.default.removeObserver($0) }
        stallObserver.map { NotificationCenter.default.removeObserver($0) }
        failureObserver.map { NotificationCenter.default.removeObserver($0) }
        preparationTimeout?.cancel()
    }
}
