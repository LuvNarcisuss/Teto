import Foundation

enum LiveRoomMode: String, CaseIterable, Identifiable {
    case choreography = "Choreography", freestyle = "Freestyle"
    var id: String { rawValue }
    var title: String { rawValue }
    var symbol: String { "figure.dance" }
}

enum LiveMediaSource: Equatable {
    case local(URL), remote(URL), coverOnly
    var url: URL? {
        switch self { case .local(let url), .remote(let url): return url; case .coverOnly: return nil }
    }
}

enum LiveVideoScaling { case fill, fit }

struct LiveRoomMedia {
    var source: LiveMediaSource
    var scaling: LiveVideoScaling = .fill
    var coverAsset: String? = nil
    var coverURL: URL? = nil
    var credit: String? = nil
    var sourceURL: URL? = nil
}

struct Streamer {
    var name: String
    var avatarAsset: String? = nil
    var likeCount = 0
}

struct AudienceMember: Identifiable {
    let id: String
    var name: String
    var avatarAsset: String? = nil
    var symbol: String = "person.fill"
}

struct UserBadge: Identifiable {
    enum Kind { case level, fan, moderator, streamer }
    let kind: Kind
    let text: String
    var id: String { "\(kind)-\(text)" }
}

struct LiveComment: Identifiable {
    enum Kind { case regular, streamer, moderator, arrival, system }
    var id = UUID()
    var nickname: String
    var text: String
    var badges: [UserBadge] = []
    var kind: Kind = .regular
    var isLocal = false
}

struct LiveRoomConfiguration: Identifiable {
    var id: String
    var mode: LiveRoomMode
    var title: String
    var streamer: Streamer
    var audience: [AudienceMember] = []
    var initialComments: [LiveComment]
    var commentLoop: [LiveComment]
    var media: LiveRoomMedia
    var sourceVideoID: UUID? = nil
    var shareText: String { "\(title) · Find your rhythm with Teto." }
}

/// Authored chat atmosphere, not a network subscription or real account activity.
/// Handles are fictional. No viewer counts, delivery receipts or transactions are generated.
enum DanceCommentScript {
    static let lines: [(String, String)] = [
        ("BeatBloom", "That footwork is so clean!"),
        ("EightCount", "Five, six, seven, eight!"),
        ("BeatBloom", "Clean!"),
        ("GrooveGarden", "The way you hit that beat!"),
        ("EightCount", "So clean"),
        ("StepStories", "That transition was smooth."),
        ("RhythmFox", "Adding this combo to my practice list."),
        ("GrooveGarden", "Hit the beat"),
        ("MotionMuse", "Love the energy in this routine."),
        ("TempoTrail", "Can we run that eight-count again?"),
        ("StepStories", "I keep rewinding that weight shift because my feet still rush it."),
        ("BeatBloom", "The shoulder groove is everything."),
        ("FlowClub", "Small steps, big confidence."),
        ("RhythmFox", "Smooth"),
        ("EightCount", "Your timing is on point."),
        ("MotionMuse", "On beat"),
        ("GrooveGarden", "That turn into the next step!"),
        ("StepStories", "What style are you practicing today?"),
        ("TempoTrail", "Love that turn"),
        ("RhythmFox", "Taking notes on that weight shift."),
        ("MotionMuse", "Such a satisfying finish."),
        ("FlowClub", "Tried the arms slowly and the footwork finally started to click."),
        ("TempoTrail", "One more round, let's go!"),
        ("BeatBloom", "Again!"),
        ("FlowClub", "Dance breaks make the day better."),
        ("BeatBloom", "The details make this combo shine."),
        ("GrooveGarden", "Love this"),
        ("EightCount", "Feel the rhythm before the next step."),
        ("GrooveGarden", "This is my sign to get up and move."),
        ("RhythmFox", "So much groove"),
        ("StepStories", "That freestyle has so much personality."),
        ("RhythmFox", "Clean lines and a relaxed groove."),
        ("TempoTrail", "The pause before that turn is the part I want in my practice."),
        ("MotionMuse", "Would love a slower breakdown of the steps."),
        ("FlowClub", "Yes!"),
        ("TempoTrail", "That little pause before the drop!"),
        ("FlowClub", "Keep moving. Keep finding your style."),
        ("EightCount", "That turn!"),
        ("BeatBloom", "That bounce feels effortless."),
        ("EightCount", "The groove starts in the knees."),
        ("StepStories", "Run it back"),
        ("GrooveGarden", "Love that change of direction."),
        ("RhythmFox", "Counting out loud helped me catch the accent I kept missing."),
        ("StepStories", "Such a clean step-touch."),
        ("RhythmFox", "Your arms tell the story."),
        ("TempoTrail", "Sharp"),
        ("MotionMuse", "That heel-toe pattern is crisp."),
        ("TempoTrail", "A little groove goes a long way."),
        ("BeatBloom", "Nice groove"),
        ("FlowClub", "Love the control in that isolation."),
        ("BeatBloom", "The rhythm is in the details."),
        ("GrooveGarden", "Watch the feet"),
        ("EightCount", "That foot slide was seamless."),
        ("StepStories", "So much personality in the way you travel across the floor."),
        ("GrooveGarden", "Nice balance through the turn."),
        ("StepStories", "The textures in this routine!"),
        ("MotionMuse", "Lovely"),
        ("RhythmFox", "Every accent has its own moment."),
        ("MotionMuse", "Those level changes are smooth."),
        ("FlowClub", "So smooth"),
        ("TempoTrail", "That last step caught my eye."),
        ("BeatBloom", "One more time"),
        ("FlowClub", "Feeling the music through movement."),
        ("BeatBloom", "This combo has a great flow."),
        ("GrooveGarden", "I want the first phrase solid before I even try the turn."),
        ("EightCount", "The rebound looks so natural."),
        ("GrooveGarden", "What a fun way to warm up."),
        ("RhythmFox", "More"),
        ("StepStories", "Love a relaxed freestyle session."),
        ("RhythmFox", "The confidence in that walk!"),
        ("TempoTrail", "Let's go"),
        ("MotionMuse", "That shoulder roll is so fluid."),
        ("FlowClub", "Feel the music"),
        ("TempoTrail", "Let the movement breathe."),
        ("FlowClub", "The foot placement is so precise."),
        ("EightCount", "Soft shapes and sharp stops still feel like one continuous phrase."),
        ("BeatBloom", "One beat, a hundred possibilities."),
        ("EightCount", "That change of pace is clever."),
        ("StepStories", "Wow"),
        ("GrooveGarden", "The groove never stops."),
        ("RhythmFox", "One more"),
        ("StepStories", "Finding a new favorite step."),
        ("RhythmFox", "Your musicality shines through."),
        ("TempoTrail", "Such clean lines"),
        ("MotionMuse", "Love the travel across the floor."),
        ("TempoTrail", "That little wrist accent!"),
        ("BeatBloom", "This phrase has room to breathe, so I want to dance it slower."),
        ("FlowClub", "The body wave is beautiful."),
        ("BeatBloom", "This sequence feels playful."),
        ("GrooveGarden", "Precise"),
        ("EightCount", "Strong shapes, soft transitions."),
        ("StepStories", "Stay loose"),
        ("GrooveGarden", "Try it slow, then find the flow."),
        ("StepStories", "Would love to learn this combo."),
        ("MotionMuse", "Need this combo"),
        ("RhythmFox", "Every practice counts."),
        ("MotionMuse", "That pivot was sharp."),
        ("FlowClub", "Fluid"),
        ("TempoTrail", "Nice control on the stop."),
        ("BeatBloom", "Gorgeous"),
        ("FlowClub", "The ending ties it all together."),
        ("BeatBloom", "Taking this energy into practice."),
        ("GrooveGarden", "Big energy"),
        ("EightCount", "Dance is a whole mood."),
        ("GrooveGarden", "That diagonal step is a nice touch."),
        ("RhythmFox", "Keep it going"),
        ("StepStories", "The timing of that release!"),
        ("RhythmFox", "Such a good use of space."),
        ("TempoTrail", "Rhythm"),
        ("MotionMuse", "A clean groove always hits."),
        ("FlowClub", "Bounce"),
        ("TempoTrail", "The small accents make it yours."),
        ("FlowClub", "The movement looks so free."),
        ("EightCount", "Those arms"),
        ("BeatBloom", "That rhythm switch is fun."),
        ("EightCount", "Love the expression in this."),
        ("StepStories", "That was smooth"),
        ("GrooveGarden", "This makes me want to practice."),
        ("RhythmFox", "Musical"),
        ("StepStories", "That slow moment adds so much."),
        ("RhythmFox", "Smooth entry into the next count."),
        ("TempoTrail", "Love it"),
        ("MotionMuse", "The footwork has its own melody."),
        ("TempoTrail", "Building confidence one combo at a time."),
        ("BeatBloom", "Mark it slowly"),
        ("FlowClub", "What inspired this routine?"),
        ("BeatBloom", "The flow between steps is lovely."),
        ("GrooveGarden", "So sharp"),
        ("EightCount", "Keeping the shoulders loose helps."),
        ("StepStories", "Yes please"),
        ("GrooveGarden", "Great energy from start to finish."),
        ("StepStories", "That turn feels perfectly placed."),
        ("MotionMuse", "Chills"),
        ("RhythmFox", "A little practice, a little progress."),
        ("MotionMuse", "The groove is contagious."),
        ("FlowClub", "The feet!"),
        ("TempoTrail", "Love the shape of that reach."),
        ("BeatBloom", "Count it"),
        ("FlowClub", "Every dancer brings a different story."),
        ("BeatBloom", "That side step has personality."),
        ("GrooveGarden", "Soft"),
        ("EightCount", "The pause makes the next move pop."),
        ("GrooveGarden", "This is a great practice reminder."),
        ("RhythmFox", "Hit it"),
        ("StepStories", "Nice rhythm through the whole combo."),
        ("RhythmFox", "Your style makes the steps unique."),
        ("TempoTrail", "So good"),
        ("MotionMuse", "Let your feet find the beat."),
        ("FlowClub", "Loose knees"),
        ("TempoTrail", "A fresh take on a familiar groove."),
        ("FlowClub", "Keep exploring your movement."),
        ("BeatBloom", "Light feet")
    ]
    static var comments: [LiveComment] { lines.map { LiveComment(nickname: $0.0, text: $0.1) } }
}

enum DanceRoomLibrary {
    static func room(video: LocalVideo, videoURL: URL, coverURL: URL, displayName: String) -> LiveRoomConfiguration {
        let opening = DanceDiscussionContent.lines(for: video).map {
            LiveComment(nickname: $0.name, text: $0.text)
        }
        let sequence = opening + DanceCommentScript.comments.shuffled()
        return LiveRoomConfiguration(id: video.id.uuidString,
            mode: video.bundledClip?.assetName == "dance-seaside" ? .freestyle : .choreography,
            title: video.title,
            streamer: Streamer(name: video.bundledClip?.creator ?? displayName,
                               avatarAsset: FreshStudioPhotos.creatorAvatar(for: video.creatorID)),
            initialComments: Array(sequence.prefix(5)), commentLoop: sequence,
            media: LiveRoomMedia(source: .local(videoURL), coverURL: coverURL,
                credit: video.bundledClip.map { "\($0.creator) / Pexels" }, sourceURL: video.bundledClip?.sourceURL), sourceVideoID: video.id)
    }
    static func featured(_ mode: LiveRoomMode) -> LiveRoomConfiguration {
        let entry = mode == .freestyle ? DanceVideoCatalog.entries[1] : DanceVideoCatalog.entries[0]
        return room(video: entry.localVideo, videoURL: entry.resourceURL(fileExtension: "mp4"),
                    coverURL: entry.resourceURL(fileExtension: "jpg"), displayName: entry.creator)
    }
}
