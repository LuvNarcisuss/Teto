import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: String
    let author: String
    let text: String
    let time: String
    let isOwn: Bool
    var createdAt: Date? = nil
    var isPending: Bool? = nil
}

struct DanceConversation: Identifiable, Hashable {
    enum Kind { case person, group, activity }
    let id: String
    let name: String
    let avatars: [String]
    let kind: Kind
    let time: String
    let initialUnread: Int
    let initiallyPinned: Bool
    let story: String?
    let messages: [ChatMessage]
    var creator: CreatorProfile? = nil
    var summary: String { messages.last?.text ?? "Start with a hello." }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct LocalChatGroup: Codable, Equatable, Identifiable {
    var id: String
    var name: String
    var avatarAssets: [String]
    var createdAt: Date
}

struct ChatLocalState: Codable {
    var readIDs: Set<String> = []
    var pinOverrides: [String: Bool] = [:]
    var drafts: [String: String] = [:]
    // Optional fields preserve decoding of earlier library snapshots.
    var sentMessages: [String: [ChatMessage]]? = nil
    var followingOverrides: [String: Bool]? = nil
    var followerIDs: Set<String>? = nil
    var createdGroups: [LocalChatGroup]? = nil
    var unreadMarks: [String: Int]? = nil
    var mutedIDs: Set<String>? = nil
    var hiddenChatIDs: Set<String>? = nil
}

enum ChatInboxFilter: String, CaseIterable, Identifiable {
    case all = "All chats", unread = "Unread", pinned = "Pinned", drafts = "Drafts"
    var id: String { rawValue }
}

/// Authored conversations, not downloaded messages or real user activity.
/// Stable IDs let local read, pin and draft state survive catalog reloads.
enum DanceChatCatalog {
    // Authored relationships for the existing fictional inbox, not remote account data.
    static let initialMutualIDs: Set<String> = ["maya", "leo", "zoe"]
    static let initialFollowerIDs: Set<String> = ["maya", "leo", "zoe", "noah"]
    private static func conversation(_ id: String, _ name: String, avatars: [String], kind: DanceConversation.Kind = .person,
                                     time: String, unread: Int = 0, pinned: Bool = false, story: String? = nil,
                                     lines: [(String, String)]) -> DanceConversation {
        let clock = time.split(separator: ":").compactMap { Int($0) }
        let endMinute = clock.count == 2 ? clock[0] * 60 + clock[1] : 13 * 60 + 30
        return DanceConversation(id: id, name: name, avatars: avatars, kind: kind, time: time,
            initialUnread: unread, initiallyPinned: pinned, story: story,
            messages: lines.enumerated().map { index, line in
                ChatMessage(id: "\(id)-\(index)", author: line.0, text: line.1,
                            time: String(format: "%02d:%02d", (endMinute - lines.count + index + 1) / 60,
                                         (endMinute - lines.count + index + 1) % 60), isOwn: line.0 == "You")
            })
    }
    static let conversations: [DanceConversation] = [
        conversation("activity", "Dance activity", avatars: ["TetoMark"], kind: .activity, time: "Today", unread: 1, lines: [
            ("Teto", "A little inspiration for your next practice."),
            ("Teto", "Pick one eight-count and try it slowly before adding speed."),
            ("Teto", "Your next move: save a routine you want to learn.")]),
        conversation("maya", "Maya Chen", avatars: ["Portrait1"], time: "13:25", unread: 2, pinned: true,
                     story: "Working on the little details. One clean eight-count at a time.", lines: [
            ("Maya", "Have you tried the new chorus combo?"),
            ("You", "Yes! The turn into the last eight-count is tricky."),
            ("Maya", "Keep your weight over your standing leg before the turn."),
            ("You", "That makes sense. I'll slow it down first."),
            ("Maya", "The shoulder accent lands just before the kick."),
            ("Maya", "Let's run that last eight-count again!")]),
        conversation("after-class", "After Class Crew", avatars: ["Portrait1", "Portrait2", "Portrait3", "Portrait4"], kind: .group, time: "12:48", unread: 4, lines: [
            ("Noah", "What are we practicing this weekend?"),
            ("You", "A short freestyle session would be fun."),
            ("Zoe", "Let's start with a groove warm-up."),
            ("Leo", "I'll bring a few house tracks."),
            ("Maya", "And we can each share one step we love."),
            ("Zoe", "Saturday practice: grooves first, combos after.")]),
        conversation("leo", "Leo Brooks", avatars: ["Portrait2"], time: "11:42", unread: 0,
                     story: "Finding a new groove in my favorite house tracks.", lines: [
            ("Leo", "That heel-toe pattern is finally starting to click."),
            ("You", "The weight shift was the key for me."),
            ("Leo", "Exactly. Small steps make a big difference."),
            ("You", "Can't wait to try it with the music."),
            ("Leo", "That footwork is getting so clean.")]),
        conversation("zoe", "Zoe Park", avatars: ["Portrait3"], time: "Yesterday", unread: 1,
                     story: "Jazz class, a good stretch, and a little progress.", lines: [
            ("Zoe", "Do you have a favorite jazz warm-up?"),
            ("You", "I usually start with gentle isolations."),
            ("Zoe", "Same! It helps me find the rhythm."),
            ("You", "Then a few slow turns before the combo."),
            ("Zoe", "The little shoulder groove made my day.")]),
        conversation("noah", "Noah Rivera", avatars: ["Portrait4"], time: "Yesterday", unread: 0,
                     story: "A fresh playlist for the next rehearsal.", lines: [
            ("Noah", "I'm making a playlist for practice."),
            ("You", "Something with a clear beat for the warm-up?"),
            ("Noah", "Absolutely. Then a few tracks with more texture."),
            ("You", "Perfect for a freestyle round."),
            ("Noah", "Found a track for our next freestyle round.")]),
        conversation("kpop-circle", "K-pop Practice Circle", avatars: ["Portrait3", "Portrait5", "Portrait6", "Portrait2"], kind: .group, time: "Thu", unread: 3, lines: [
            ("Aria", "Which chorus should we learn next?"),
            ("Zoe", "Let's pick something with clear formations."),
            ("You", "We could split it into two eight-counts."),
            ("Finn", "I'll work on the second part first."),
            ("Aria", "Chorus breakdown: start slow and hit the accents.")]),
        conversation("aria", "Aria Wilson", avatars: ["Portrait5"], time: "Wed", unread: 0,
                     story: "Learning to let the music lead.", lines: [
            ("Aria", "I keep rushing through the pauses."),
            ("You", "Try counting the silence as part of the combo."),
            ("Aria", "That's a really helpful way to think about it."),
            ("Aria", "The pause makes the next move feel bigger.")]),
        conversation("finn", "Finn Taylor", avatars: ["Portrait6"], time: "Tue", unread: 2,
                     story: "Today's goal: stay relaxed and keep moving.", lines: [
            ("Finn", "Any tips for feeling less stiff on camera?"),
            ("You", "I do one take just for fun before filming."),
            ("Finn", "Love that. Less pressure, more movement."),
            ("Finn", "One more take, then a well-earned stretch!")]),
        conversation("ballet-friends", "Ballet & Balance", avatars: ["Portrait7", "Portrait8", "Portrait1", "Portrait5"], kind: .group, time: "Mon", unread: 0, lines: [
            ("Ivy", "A tiny balance win at the barre today."),
            ("You", "Those little wins add up."),
            ("Maya", "Absolutely. Consistency over perfection."),
            ("Ivy", "See you at the next practice.")])
    ]
    static var people: [DanceConversation] { conversations.filter { $0.kind == .person } }
}
