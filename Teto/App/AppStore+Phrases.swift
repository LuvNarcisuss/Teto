import Foundation

struct PhraseFeed {
    var kept: [DancePhrase]
    var yours: [DancePhrase]
    var catalog: [DancePhrase]
}

@MainActor
extension AppStore {
    func phraseFeed() -> PhraseFeed {
        let book = normalizedBook()
        let keptIDs = Set(book.keptOrder)
        let kept = book.keptOrder.compactMap { phraseRecord(id: $0) }.filter { !hidesPhrase($0) }
        let yours = book.phrases.map(present).filter { !hidesPhrase($0) && !keptIDs.contains($0.id) }
            .sorted { $0.createdAt > $1.createdAt }
        let catalog = DancePhraseCatalog.phrases.map(present)
            .filter { !hidesPhrase($0) && !keptIDs.contains($0.id) }
        return PhraseFeed(kept: kept, yours: yours, catalog: catalog)
    }

    /// A phrase that can still be opened. Hidden phrases return nil.
    func phrase(id: String) -> DancePhrase? {
        guard let found = phraseRecord(id: id), !hidesPhrase(found) else { return nil }
        return found
    }

    /// Catalog and device phrases, including ones hidden by a report or a block.
    func phraseRecord(id: String) -> DancePhrase? {
        if let stored = library.phraseBook?.phrases.first(where: { $0.id == id }) {
            return present(stored)
        }
        if let catalog = DancePhraseCatalog.phrases.first(where: { $0.id == id }) {
            return present(catalog)
        }
        return nil
    }

    func visibleBranches(of parentID: String) -> [DancePhrase] {
        let book = normalizedBook()
        return book.phrases.map(present)
            .filter { $0.parentID == parentID && !hidesPhrase($0) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func hidesPhrase(_ phrase: DancePhrase) -> Bool {
        isContentReported(phrase.id, kind: .phrase) || isCreatorBlocked(phrase.authorID)
    }

    func learnedMarks(for id: String) -> [Bool] {
        guard let phrase = phraseRecord(id: id) else { return [] }
        let stored = library.phraseBook?.learned[DancePhraseCatalog.learnedKey(for: id)] ?? []
        if stored.count == phrase.eights.count { return stored }
        return Array(repeating: false, count: phrase.eights.count)
    }

    func isPhraseKept(_ id: String) -> Bool {
        library.phraseBook?.keptOrder.contains(id) == true
    }

    /// Visible phrases written by this dancer, kept ones first.
    func phrases(byAuthor id: String) -> [DancePhrase] {
        let feed = phraseFeed()
        return (feed.kept + feed.yours + feed.catalog).filter { $0.authorID == id }
    }

    /// The id inside `teto://phrase/{id}`, when a message carries one.
    func phraseID(in text: String) -> String? {
        let marker = "teto://phrase/"
        guard let range = text.range(of: marker) else { return nil }
        let id = text[range.upperBound...].prefix { $0.isLetter || $0.isNumber || $0 == "-" }
        return id.isEmpty ? nil : String(id)
    }

    func savePhrase(_ phrase: DancePhrase, videoURL: URL? = nil, coverData: Data? = nil) async -> Bool {
        guard isLoaded, !isBusy else { return false }
        noteSaveError(nil)
        if DancePhraseCatalog.phrases.contains(where: { $0.id == phrase.id }) {
            noteSaveError("This phrase could not be saved. Please try again.")
            return false
        }
        var stored = phrase.trimmed()
        stored.authorID = "local-owner"
        stored.authorName = library.profile.displayName
        if DancePhrase.validate(title: stored.title, eights: stored.eights) != nil {
            noteSaveError(PhraseText.validation)
            return false
        }
        let eightLines = stored.eights.flatMap { $0 }
        var authoredText = [stored.title] + eightLines
        if let lesson = stored.lesson {
            let actionLines = lesson.actions.flatMap { section in section.map(\.instruction) }
            authoredText.append(lesson.closingInstruction)
            authoredText.append(contentsOf: actionLines)
            if lesson.bundledAsset == nil {
                authoredText.append(lesson.credits)
            }
        }
        if authoredText.contains(where: { !PhraseText.permitsAuthoredText($0) }) {
            noteSaveError("Use dance and practice wording for your phrase.")
            return false
        }
        if let error = stored.lesson?.validationError(eights: stored.eights, requireMedia: videoURL == nil) {
            noteSaveError(error)
            return false
        }
        if let parentID = stored.parentID {
            if let parent = phraseRecord(id: parentID) {
                let indexes = DancePhrase.changedEightIndexes(from: parent.eights, to: stored.eights)
                if indexes.isEmpty, stored.lesson == lessonSnapshot(for: parent),
                   stored.title == parent.title, stored.style == parent.style, stored.tempo == parent.tempo {
                    noteSaveError(PhraseText.sameAsParent)
                    return false
                }
                stored.changedEights = indexes
                stored.parentTitle = parent.title
            } else if stored.changedEights?.isEmpty != false {
                stored.changedEights = Array(1...stored.eights.count)
            }
        } else {
            stored.parentTitle = nil
            stored.changedEights = nil
        }
        var updated = library
        var book = updated.phraseBook ?? PhraseBookState()
        let previous = book.phrases.first { $0.id == stored.id }
        if let index = book.phrases.firstIndex(where: { $0.id == stored.id }) {
            book.phrases[index] = stored
        } else {
            book.phrases.insert(stored, at: 0)
        }
        book.learned[stored.id] = learnedMarks(afterReplacing: previous, with: stored, existing: book.learned[stored.id])
        updated.phraseBook = book
        return await persistPhrase(stored, updated: updated, videoURL: videoURL, coverData: coverData)
    }

    func deletePhrase(id: String) async -> Bool {
        guard isLoaded, !isBusy else { return false }
        if DancePhraseCatalog.phrases.contains(where: { $0.id == id }) { return false }
        var updated = library
        var book = updated.phraseBook ?? PhraseBookState()
        let before = book.phrases.count
        let oldLesson = book.phrases.first { $0.id == id }?.lesson
        book.phrases.removeAll { $0.id == id }
        guard book.phrases.count != before else { return false }
        book.keptOrder.removeAll { $0 == id }
        book.learned[id] = nil
        updated.phraseBook = book
        guard await commit(updated) else { return false }
        await releasePhraseMedia(oldLesson)
        return true
    }

    func toggleKept(id: String) async -> Bool {
        guard isLoaded, !isBusy, phraseRecord(id: id) != nil else { return false }
        var updated = library
        var book = updated.phraseBook ?? PhraseBookState()
        if let index = book.keptOrder.firstIndex(of: id) {
            book.keptOrder.remove(at: index)
        } else {
            book.keptOrder.insert(id, at: 0)
        }
        updated.phraseBook = book
        return await commit(updated)
    }

    func toggleLearned(id: String, eightIndex: Int) async -> Bool {
        guard isLoaded, !isBusy, let phrase = phraseRecord(id: id),
            phrase.eights.indices.contains(eightIndex)
        else { return false }
        var updated = library
        var book = updated.phraseBook ?? PhraseBookState()
        let key = DancePhraseCatalog.learnedKey(for: id)
        var marks = book.learned[key] ?? Array(repeating: false, count: phrase.eights.count)
        if marks.count != phrase.eights.count {
            marks = Array(repeating: false, count: phrase.eights.count)
        }
        marks[eightIndex].toggle()
        book.learned[key] = marks
        updated.phraseBook = book
        return await commit(updated)
    }

    private func normalizedBook() -> PhraseBookState {
        let catalogIDs = Set(DancePhraseCatalog.phrases.map(\.id))
        return (library.phraseBook ?? PhraseBookState()).normalized(catalogIDs: catalogIDs)
    }

    private func present(_ phrase: DancePhrase) -> DancePhrase {
        var copy = phrase
        if copy.authorID == "local-owner" {
            copy.authorName = library.profile.displayName
        }
        return copy
    }

    private func learnedMarks(
        afterReplacing previous: DancePhrase?, with stored: DancePhrase, existing: [Bool]?
    ) -> [Bool] {
        let count = stored.eights.count
        guard let previous else { return existing ?? Array(repeating: false, count: count) }
        if (previous.lesson == nil) != (stored.lesson == nil)
            || previous.lesson?.localVideo?.id != stored.lesson?.localVideo?.id
            || previous.lesson?.bundledAsset != stored.lesson?.bundledAsset
            || previous.lesson?.duration != stored.lesson?.duration {
            return Array(repeating: false, count: count)
        }
        var changed = Set(DancePhrase.changedEightIndexes(from: previous.eights, to: stored.eights))
        if let before = previous.lesson, let after = stored.lesson {
            for index in 0..<count where !before.actions.indices.contains(index) || before.actions[index] != after.actions[index] {
                changed.insert(index + 1)
            }
        }
        let prior = existing ?? Array(repeating: false, count: previous.eights.count)
        return (0..<count).map { index in
            let eightNumber = index + 1
            if changed.contains(eightNumber) || index >= prior.count { return false }
            return prior[index]
        }
    }

    func lessonSnapshot(for phrase: DancePhrase) -> PhraseLesson? {
        if let lesson = phrase.lesson { return lesson }
        guard let timeline = DancePhraseCatalog.timelines[phrase.id] else { return nil }
        var previous: TimeInterval = 0
        let actions = timeline.eights.indices.map { section in
            timeline.eights[section].indices.map { offset -> PhraseActionTiming in
                let action = timeline.action(timeline.actionIndex(section: section, offset: offset)!)!
                let instruction = timeline.cues.first { !$0.isAction && $0.start == previous }?.text ?? "Watch the instruction"
                previous = action.end
                return PhraseActionTiming(start: action.start, end: action.end, instruction: instruction)
            }
        }
        return PhraseLesson(bundledAsset: timeline.assetName, duration: timeline.duration, actions: actions,
                            closingInstruction: timeline.cues.last?.isAction == false ? timeline.cues.last!.text : "Finish the lesson",
                            credits: DancePhraseCatalog.filmCredits[timeline.assetName] ?? "", pickupBPM: Int(60 / phrase.tempo.beatDuration))
    }

    func phraseTimeline(for phrase: DancePhrase) -> PhraseFilmTimeline? {
        phrase.lesson?.timeline(eights: phrase.eights) ?? DancePhraseCatalog.timelines[phrase.id]
    }

    func phraseVideoURL(for phrase: DancePhrase) -> URL? {
        if let lesson = phrase.lesson {
            if let video = lesson.localVideo { return videoURL(video) }
            if let asset = lesson.bundledAsset {
                return DanceVideoCatalog.entries.first { $0.assetName == asset }?.resourceURL(fileExtension: "mp4")
            }
        }
        if let asset = DancePhraseCatalog.filmAsset[phrase.id] {
            return DanceVideoCatalog.entries.first { $0.assetName == asset }?.resourceURL(fileExtension: "mp4")
        }
        // Retain the former video-only fallback for older text branches without asserting timing.
        var parent = phrase.parentID
        var seen: Set<String> = [phrase.id]
        while let id = parent, seen.insert(id).inserted, let record = phraseRecord(id: id) {
            if record.lesson != nil || DancePhraseCatalog.filmAsset[id] != nil { return phraseVideoURL(for: record) }
            parent = record.parentID
        }
        return nil
    }

    func phraseCoverURL(for phrase: DancePhrase) -> URL? {
        if let lesson = phrase.lesson {
            if let id = lesson.coverID { return storageRoot.appendingPathComponent("Media/\(id.uuidString).jpg") }
            if let video = lesson.localVideo { return coverURL(video) }
            if let asset = lesson.bundledAsset {
                return DanceVideoCatalog.entries.first { $0.assetName == asset }?.resourceURL(fileExtension: "jpg")
            }
        }
        if let asset = DancePhraseCatalog.filmAsset[phrase.id] {
            return DanceVideoCatalog.entries.first { $0.assetName == asset }?.resourceURL(fileExtension: "jpg")
        }
        return nil
    }
}
