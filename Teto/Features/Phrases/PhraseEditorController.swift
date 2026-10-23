import AVFoundation
import PhotosUI
import UIKit
import UniformTypeIdentifiers

final class PhraseEditorController: StackScreen, UITextFieldDelegate, PHPickerViewControllerDelegate {
    enum Mode { case create, branch(DancePhrase), edit(DancePhrase) }
    private let mode: Mode
    private let phraseID: String
    private let createdAt: Date
    private let parentID: String?
    private let parentTitle: String?
    private var style: PhraseStyle
    private var tempo: PhraseTempo
    private var eights: [[String]]
    private var lesson: PhraseLesson?
    private var eightIndex = 0
    private var titleField: UITextField?
    private var countFields: [UITextField] = []
    private var startFields: [UITextField] = [], endFields: [UITextField] = [], instructionFields: [UITextField] = []
    private var creditsField: UITextView?
    private var closingField: UITextField?
    private var bpmField: UITextField?
    private var eightHeading: UILabel?
    private var removeButton: StudioButton?, addButton: StudioButton?
    private var saveButton: StudioButton?
    private let mediaStatus = label("Add a dance video to build your lesson.", 14, TetoTheme.muted)
    private let videoView = VideoLayerView()
    private let coverView = UIImageView()
    private let scrubber = UISlider()
    private let videoTime = label("0:00", 14, TetoTheme.emerald)
    private let consent = StudioSwitch()
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var temporaryVideo: URL?
    private var coverData: Data?
    private var mediaGeneration = 0
    private var selecting = false, makingCover = false, saving = false
    private var oldSwipeEnabled: Bool?
    private struct Snapshot: Equatable {
        let style: PhraseStyle
        let tempo: PhraseTempo
        let eights: [[String]]
        let title: String
        let lesson: PhraseLesson?
    }
    private let baseline: Snapshot

    init(store: AppStore, mode: Mode) {
        self.mode = mode
        switch mode {
        case .create:
            phraseID = UUID().uuidString; createdAt = Date(); parentID = nil; parentTitle = nil
            style = .hipHop; tempo = .slow; eights = [[""]]; lesson = nil
        case .branch(let source):
            phraseID = UUID().uuidString; createdAt = Date(); parentID = source.id; parentTitle = source.title
            style = source.style; tempo = source.tempo; eights = source.eights
            lesson = store.lessonSnapshot(for: source)
        case .edit(let source):
            phraseID = source.id; createdAt = source.createdAt; parentID = source.parentID; parentTitle = source.parentTitle
            style = source.style; tempo = source.tempo; eights = source.eights; lesson = source.lesson
        }
        let initialTitle: String
        switch mode { case .create: initialTitle = ""; case .branch(let source), .edit(let source): initialTitle = source.title }
        baseline = Snapshot(style: style, tempo: tempo, eights: eights, title: initialTitle, lesson: lesson)
        let heading: String
        switch mode { case .create: heading = "New phrase"; case .branch: heading = "Branch"; case .edit: heading = "Edit phrase" }
        super.init(store: store, title: heading)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

    override func build() {
        super.build()
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEditing))
        let titleField = field("Title", text: baseline.title)
        titleField.delegate = self
        self.titleField = titleField
        content.addArrangedSubview(titleField)
        if let parentTitle { content.addArrangedSubview(label("From \(parentTitle)", 14, TetoTheme.muted)) }
        content.addArrangedSubview(label("Saved on this device. Your name and photo come from your profile.", 13, TetoTheme.muted))
        content.addArrangedSubview(label("Style", 14, TetoTheme.emerald))
        let styles = StudioChoice(items: PhraseStyle.allCases.map(\.title), index: PhraseStyle.allCases.firstIndex(of: style) ?? 0)
        styles.onChange = { [weak self] in self?.style = PhraseStyle.allCases[$0] }
        content.addArrangedSubview(styles)
        content.addArrangedSubview(actionButton("Choose a dance video", icon: .shorts) { [weak self] in self?.chooseVideo() })
        content.addArrangedSubview(label("One dancer, up to 30 minutes and 250 MB. Use English speech and on-screen text.", 13, TetoTheme.muted))
        content.addArrangedSubview(mediaStatus)
        videoView.backgroundColor = .black
        videoView.layer.cornerRadius = 16
        videoView.clipsToBounds = true
        videoView.heightAnchor.constraint(equalToConstant: 230).isActive = true
        videoView.videoLayer.videoGravity = .resizeAspect
        content.addArrangedSubview(videoView)
        scrubber.minimumValue = 0; scrubber.maximumValue = Float(lesson?.duration ?? 1)
        scrubber.accessibilityLabel = "Video position"
        scrubber.addTarget(self, action: #selector(scrubVideo), for: .valueChanged)
        content.addArrangedSubview(scrubber)
        content.addArrangedSubview(videoTime)
        let play = actionButton("Play / pause", icon: .play) { [weak self] in
            guard let self else { return }
            if self.player?.rate == 0 {
                if let time = self.player?.currentTime().seconds, time >= (self.lesson?.duration ?? 0) - 0.01 {
                    self.player?.seek(to: .zero)
                }
                self.player?.play()
            } else { self.player?.pause() }
        }
        let cover = actionButton("Use this frame as cover", icon: .photo) { [weak self] in self?.chooseCover() }
        content.addArrangedSubview(stack([play, cover], axis: .horizontal, spacing: 8))
        coverView.contentMode = .scaleAspectFill; coverView.clipsToBounds = true; coverView.layer.cornerRadius = 16
        coverView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        coverView.backgroundColor = TetoTheme.line
        coverView.accessibilityLabel = "Phrase cover"
        content.addArrangedSubview(coverView)
        content.addArrangedSubview(label("Default playback speed", 14, TetoTheme.emerald))
        let rates: [Double] = [0.5, 0.75, 1]
        let speeds = StudioChoice(items: ["0.5x", "0.75x", "1x"], index: rates.firstIndex(of: lesson?.defaultRate ?? 1) ?? 2)
        speeds.onChange = { [weak self] index in
            self?.ensureLessonDraft()
            self?.lesson?.defaultRate = rates[index]
        }
        content.addArrangedSubview(speeds)
        content.addArrangedSubview(label("Start with", 14, TetoTheme.emerald))
        let startMode = StudioChoice(items: ["Whole lesson", "First section loop"], index: lesson?.startsWithLoop == true ? 1 : 0)
        startMode.onChange = { [weak self] index in
            self?.ensureLessonDraft()
            self?.lesson?.startsWithLoop = index == 1
        }
        content.addArrangedSubview(startMode)
        let bpm = field("Preparation tempo (40–180 BPM)", text: String(lesson?.pickupBPM ?? 80))
        bpm.keyboardType = .numberPad; bpmField = bpm
        content.addArrangedSubview(bpm)
        content.addArrangedSubview(label("Every loop starts with 5, 6, 7, 8. Preparation slows down with playback speed.", 13, TetoTheme.muted))
        if case .edit = mode, baseline.lesson == nil {
            content.addArrangedSubview(label("Counts without a video", 14, TetoTheme.emerald))
            let tempos = StudioChoice(items: PhraseTempo.allCases.map(\.title), index: PhraseTempo.allCases.firstIndex(of: tempo) ?? 0)
            tempos.onChange = { [weak self] in self?.tempo = PhraseTempo.allCases[$0] }
            content.addArrangedSubview(tempos)
        }
        content.addArrangedSubview(label("Write each action in English. Pause the video and mark each action's start and end, or enter seconds. Leave unused trailing counts blank.", 14, TetoTheme.muted))
        let heading = label("", 16, title: true); eightHeading = heading; content.addArrangedSubview(heading)
        for index in 0..<8 {
            let text = field("Count \(index + 1)")
            text.delegate = self; countFields.append(text)
            content.addArrangedSubview(text)
            let start = field("Start (seconds)"), end = field("End (seconds)")
            start.keyboardType = .decimalPad; end.keyboardType = .decimalPad
            startFields.append(start); endFields.append(end)
            let times = stack([start, end], axis: .horizontal, spacing: 8); times.distribution = .fillEqually
            content.addArrangedSubview(times)
            let markStart = actionButton("Mark start", icon: .check, compact: true) { [weak self] in self?.mark(index, start: true) }
            let markEnd = actionButton("Mark end", icon: .check, compact: true) { [weak self] in self?.mark(index, start: false) }
            let go = actionButton("Go to start", icon: .play, compact: true) { [weak self] in self?.goToCount(index) }
            let buttons = stack([markStart, markEnd, go], axis: .horizontal, spacing: 6); buttons.distribution = .fillEqually
            content.addArrangedSubview(buttons)
            let instruction = field("Instruction before this count")
            instructionFields.append(instruction); content.addArrangedSubview(instruction)
        }
        let previous = actionButton("Previous section", icon: .back) { [weak self] in self?.moveEight(-1) }
        let next = actionButton("Next section", icon: .forward) { [weak self] in self?.moveEight(1) }
        let pager = stack([previous, next], axis: .horizontal, spacing: 8); pager.distribution = .fillEqually
        content.addArrangedSubview(pager)
        let add = actionButton("Add a section", icon: .plus) { [weak self] in self?.addEight() }
        let remove = actionButton("Remove this section", icon: .trash, tone: .danger) { [weak self] in self?.removeEight() }
        addButton = add; removeButton = remove
        content.addArrangedSubview(add); content.addArrangedSubview(remove)
        let closing = field("Closing instruction", text: lesson?.closingInstruction ?? "Finish the lesson")
        closingField = closing; content.addArrangedSubview(closing)
        content.addArrangedSubview(label("Video credits and permission", 14, TetoTheme.emerald))
        let credits = UITextView()
        credits.font = TetoTheme.font(15); credits.backgroundColor = .white; credits.layer.cornerRadius = 12
        credits.heightAnchor.constraint(equalToConstant: 120).isActive = true
        credits.text = lesson?.credits ?? ""
        credits.accessibilityLabel = "Video creator, source and permission"
        credits.isEditable = lesson?.bundledAsset == nil
        creditsField = credits; content.addArrangedSubview(credits)
        content.addArrangedSubview(label("Name the video creator and source, and describe your permission to use it. Existing source credits stay attached to a branch.", 13, TetoTheme.muted))
        let consentText = "This is a single-person dance video in English, and I have permission to use the video and cover."
        consent.accessibilityLabel = consentText
        let consentRow = stack([label(consentText, 14), consent], axis: .horizontal, spacing: 8)
        consentRow.alignment = .center; content.addArrangedSubview(consentRow)
        let save = actionButton("Save phrase", icon: .check, primary: true) { [weak self] in self?.savePhrase() }
        saveButton = save; content.addArrangedSubview(save)
        showEight()
        if let url = existingVideoURL() { installPlayer(url) }
        if case .edit(let source) = mode, let url = store.phraseCoverURL(for: source) { coverView.image = UIImage(contentsOfFile: url.path) }
        if case .branch(let source) = mode, let url = store.phraseCoverURL(for: source) { coverView.image = UIImage(contentsOfFile: url.path) }
    }

    override func refresh() {}
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oldSwipeEnabled == nil { oldSwipeEnabled = navigationController?.interactivePopGestureRecognizer?.isEnabled }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        if let enabled = oldSwipeEnabled { navigationController?.interactivePopGestureRecognizer?.isEnabled = enabled }
    }

    private func existingVideoURL() -> URL? {
        if let temporaryVideo { return temporaryVideo }
        if let video = lesson?.localVideo { return store.videoURL(video) }
        if let asset = lesson?.bundledAsset { return DanceVideoCatalog.entries.first { $0.assetName == asset }?.resourceURL(fileExtension: "mp4") }
        return nil
    }

    private func ensureLessonDraft() {
        if lesson == nil {
            lesson = PhraseLesson(duration: 0, actions: eights.map { $0.map { _ in PhraseActionTiming() } }, credits: creditsField?.text ?? "")
        }
    }

    private func installPlayer(_ url: URL) {
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        let player = AVPlayer(url: url); self.player = player; videoView.videoLayer.player = player
        scrubber.maximumValue = Float(lesson?.duration ?? 1)
        mediaStatus.text = "Video ready. Set your cover and action times."
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
            MainActor.assumeIsolated {
                guard let self, time.seconds.isFinite else { return }
                if !self.scrubber.isTracking { self.scrubber.value = Float(time.seconds) }
                self.videoTime.text = String(format: "%.2f / %.2f seconds", time.seconds, self.lesson?.duration ?? 0)
            }
        }
    }

    @objc private func scrubVideo() {
        player?.pause()
        player?.seek(to: CMTime(seconds: Double(scrubber.value), preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
    }
    private func mark(_ index: Int, start: Bool) {
        guard let player, player.currentItem?.status == .readyToPlay else { message("Add a video and wait for it to open first."); return }
        player.pause()
        let time = player.currentTime().seconds
        guard time.isFinite else { return }
        (start ? startFields[index] : endFields[index]).text = String(time)
    }
    private func goToCount(_ index: Int) {
        guard let time = Double((startFields[index].text ?? "").replacingOccurrences(of: ",", with: ".")), time.isFinite,
              time >= 0, time < (lesson?.duration ?? 0) else { return }
        player?.pause(); player?.seek(to: CMTime(seconds: time, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
    }

    private func chooseVideo() {
        guard !selecting, !saving, !makingCover else { return }
        commitFields()
        let choose = { [weak self] in
            guard let self else { return }
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .videos; config.selectionLimit = 1; config.preferredAssetRepresentationMode = .current
            let picker = PHPickerViewController(configuration: config); picker.delegate = self
            self.present(picker, animated: true)
        }
        if existingVideoURL() != nil {
            confirm("Replace this video?", message: "Your count text stays. Set new action times and choose a new cover for the replacement video.", button: "Choose video", action: choose)
        } else { choose() }
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider else { return }
        selecting = true; mediaGeneration += 1
        let request = mediaGeneration
        mediaStatus.text = "Opening video…"
        provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, _ in
            var temporary: URL?
            do {
                guard let url else { throw LocalLibraryError.importFailed }
                let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                guard size > 0, size <= 250 * 1_024 * 1_024 else { throw LocalLibraryError.videoTooLarge }
                let ext = url.pathExtension.lowercased()
                guard ["mov", "mp4", "m4v"].contains(ext) else { throw LocalLibraryError.invalidVideo }
                let target = FileManager.default.temporaryDirectory.appendingPathComponent("teto-phrase-\(UUID().uuidString).\(ext)")
                try FileManager.default.copyItem(at: url, to: target); temporary = target
            } catch { }
            let importedURL = temporary
            Task { @MainActor [weak self] in
                guard let self, self.mediaGeneration == request else { if let importedURL { try? FileManager.default.removeItem(at: importedURL) }; return }
                guard let importedURL else { self.selecting = false; self.mediaStatus.text = "Choose an MP4, MOV or M4V dance video up to 250 MB."; return }
                do {
                    let asset = AVURLAsset(url: importedURL)
                    let duration = try await asset.load(.duration).seconds
                    let tracks = try await asset.loadTracks(withMediaType: .video)
                    guard duration.isFinite, duration > 0, duration <= 1_800, !tracks.isEmpty else { throw LocalLibraryError.invalidVideo }
                    guard self.mediaGeneration == request else { try? FileManager.default.removeItem(at: importedURL); return }
                    self.commitFields(); self.ensureLessonDraft()
                    if let old = self.temporaryVideo { try? FileManager.default.removeItem(at: old) }
                    self.temporaryVideo = importedURL
                    self.lesson?.localVideo = nil; self.lesson?.bundledAsset = nil; self.lesson?.coverID = nil
                    self.lesson?.duration = duration; self.lesson?.coverTime = 0
                    self.lesson?.actions = self.eights.map { $0.map { _ in PhraseActionTiming() } }
                    self.creditsField?.isEditable = true
                    self.creditsField?.text = ""
                    self.coverData = nil; self.coverView.image = nil; self.consent.isOn = false
                    self.selecting = false; self.installPlayer(importedURL); self.showEight()
                    self.chooseCover(at: 0)
                } catch {
                    try? FileManager.default.removeItem(at: importedURL)
                    self.selecting = false; self.mediaStatus.text = "This video could not be opened. Choose a video up to 30 minutes."
                }
            }
        }
    }

    private func chooseCover(at requestedTime: TimeInterval? = nil) {
        guard let url = existingVideoURL(), let duration = lesson?.duration, duration > 0, !selecting, !saving else { return }
        player?.pause()
        let time = min(max(0, requestedTime ?? player?.currentTime().seconds ?? 0), max(0, duration - 1.0 / 600))
        guard time.isFinite else { return }
        makingCover = true; mediaGeneration += 1
        let request = mediaGeneration
        Task { [weak self] in
            guard let self else { return }
            do {
                let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
                generator.appliesPreferredTrackTransform = true; generator.maximumSize = CGSize(width: 900, height: 1_200)
                generator.requestedTimeToleranceBefore = .zero
                generator.requestedTimeToleranceAfter = .zero
                let frame = try await generator.image(at: CMTime(seconds: time, preferredTimescale: 600))
                guard self.mediaGeneration == request else { return }
                let image = UIImage(cgImage: frame.image)
                guard let data = image.jpegData(compressionQuality: 0.85) else { throw LocalLibraryError.importFailed }
                let actualTime = frame.actualTime.seconds
                guard actualTime.isFinite, actualTime >= 0, actualTime < duration else { throw LocalLibraryError.importFailed }
                self.coverData = data; self.coverView.image = image; self.lesson?.coverTime = actualTime
                self.mediaStatus.text = String(format: "Cover at %.2f seconds. Set each action's video times.", actualTime)
            } catch {
                if self.mediaGeneration == request { self.mediaStatus.text = "This frame could not be used. Choose another frame." }
            }
            if self.mediaGeneration == request { self.makingCover = false }
        }
    }

    private func commitFields() {
        guard eights.indices.contains(eightIndex), !countFields.isEmpty else { return }
        var lines = countFields.map { ($0.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        while lines.count > 1, lines.last?.isEmpty == true { lines.removeLast() }
        eights[eightIndex] = lines
        if lesson != nil {
            while lesson!.actions.count < eights.count { lesson!.actions.append([]) }
            lesson?.actions[eightIndex] = lines.indices.map { index in
                let start = Double((startFields[index].text ?? "").replacingOccurrences(of: ",", with: ".")) ?? -1
                let end = Double((endFields[index].text ?? "").replacingOccurrences(of: ",", with: ".")) ?? -1
                return PhraseActionTiming(start: start, end: end, instruction: instructionFields[index].text ?? "")
            }
            lesson?.pickupBPM = Int(bpmField?.text ?? "") ?? 0
            lesson?.credits = creditsField?.text ?? ""
            lesson?.closingInstruction = closingField?.text ?? ""
        }
    }
    private func showEight() {
        eightHeading?.text = "Section \(eightIndex + 1) of \(eights.count)"
        for index in 0..<8 {
            countFields[index].text = eights[eightIndex].indices.contains(index) ? eights[eightIndex][index] : ""
            let timing = lesson?.actions.indices.contains(eightIndex) == true && lesson!.actions[eightIndex].indices.contains(index) ? lesson!.actions[eightIndex][index] : PhraseActionTiming()
            startFields[index].text = timing.start.isFinite && timing.start >= 0 ? String(timing.start) : ""
            endFields[index].text = timing.end.isFinite && timing.end >= 0 ? String(timing.end) : ""
            instructionFields[index].text = timing.instruction
        }
        addButton?.isEnabled = eights.count < DancePhrase.maximumSections
        removeButton?.isEnabled = eights.count > 1
    }
    private func moveEight(_ delta: Int) {
        commitFields(); let next = eightIndex + delta
        guard eights.indices.contains(next) else { return }
        eightIndex = next; showEight()
    }
    private func addEight() {
        guard eights.count < DancePhrase.maximumSections else { return }
        commitFields(); eights.append(Array(repeating: "", count: 8))
        lesson?.actions.append(Array(repeating: PhraseActionTiming(), count: 8))
        eightIndex = eights.count - 1; showEight()
    }
    private func removeEight() {
        guard eights.count > 1 else { return }
        commitFields()
        confirm("Remove this section?", message: "Its counts and action times will be removed from this phrase.", destructive: true, button: "Remove") { [weak self] in
            guard let self else { return }
            self.eights.remove(at: self.eightIndex)
            self.lesson?.actions.remove(at: self.eightIndex)
            self.eightIndex = min(self.eightIndex, self.eights.count - 1); self.showEight()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { textField.resignFirstResponder(); return true }

    private func savePhrase() {
        guard !selecting, !makingCover, !saving else { message("Wait for the video and cover to finish opening."); return }
        view.endEditing(true); commitFields(); player?.pause()
        let allowsLegacyText: Bool
        if case .edit = mode { allowsLegacyText = baseline.lesson == nil && lesson == nil } else { allowsLegacyText = false }
        if !allowsLegacyText {
            guard let lesson, existingVideoURL() != nil else { message("Add a dance video before saving."); return }
            guard consent.isOn else { message("Confirm the video is English dance content and you have permission to use it."); return }
            if let error = lesson.validationError(eights: eights, requireMedia: temporaryVideo == nil) { message(error); return }
            guard coverData != nil || lesson.coverID != nil || lesson.localVideo != nil || lesson.bundledAsset != nil else { message("Choose a cover frame before saving."); return }
        }
        let phrase = DancePhrase(id: phraseID, title: titleField?.text ?? "", style: style, tempo: tempo, eights: eights,
                                 authorID: "local-owner", authorName: store.library.profile.displayName,
                                 parentID: parentID, parentTitle: parentTitle, changedEights: nil, createdAt: createdAt, lesson: lesson)
        saving = true; content.isUserInteractionEnabled = false
        saveButton?.isEnabled = false; navigationItem.leftBarButtonItem?.isEnabled = false
        Task { [weak self] in
            guard let self else { return }
            let saved = await self.store.savePhrase(phrase, videoURL: self.temporaryVideo, coverData: self.coverData)
            self.saving = false; self.content.isUserInteractionEnabled = true
            self.saveButton?.isEnabled = true; self.navigationItem.leftBarButtonItem?.isEnabled = true
            if saved, let nav = self.navigationController {
                var screens = nav.viewControllers; screens.removeLast()
                if let detail = screens.last as? PhraseDetailController, detail.phraseID == self.phraseID { screens.removeLast() }
                screens.append(PhraseDetailController(store: self.store, phraseID: self.phraseID))
                nav.setViewControllers(screens, animated: true)
            } else { self.message(self.store.lastSaveError ?? "Your phrase could not be saved. Please try again.") }
        }
    }
    @objc private func cancelEditing() {
        guard !saving else { return }
        view.endEditing(true); commitFields()
        let current = Snapshot(style: style, tempo: tempo, eights: eights, title: titleField?.text ?? "", lesson: lesson)
        let leave: () -> Void = { [weak self] in
            self?.mediaGeneration += 1
            self?.navigationController?.popViewController(animated: true)
        }
        let unboundMediaEdits = lesson == nil && (
            (startFields + endFields).contains { !($0.text ?? "").isEmpty }
            || !(creditsField?.text ?? "").isEmpty
            || (bpmField?.text ?? "80") != "80"
            || (closingField?.text ?? "Finish the lesson") != "Finish the lesson")
        if current == baseline, temporaryVideo == nil, coverData == nil, !unboundMediaEdits { leave() }
        else { confirm("Leave without saving?", message: "Your saved phrase stays unchanged.", button: "Leave", action: leave) }
    }
    deinit {
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        if let temporaryVideo { try? FileManager.default.removeItem(at: temporaryVideo) }
    }
}
