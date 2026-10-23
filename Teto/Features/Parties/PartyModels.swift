import Foundation

enum PartyCategory: String, CaseIterable, Identifiable {
    case hipHop, kPop, jazz, freestyle, ballet, house
    var id: String { rawValue }
    var title: String {
        switch self {
        case .hipHop: return "Hip-hop"; case .kPop: return "K-pop"; case .jazz: return "Jazz"
        case .freestyle: return "Freestyle"; case .ballet: return "Ballet"; case .house: return "House"
        }
    }
    var asset: String { "PartyCategory-\(rawValue)" }
    var symbol: String {
        switch self {
        case .hipHop: return "waveform"; case .kPop: return "star.fill"; case .jazz: return "music.note"
        case .freestyle: return "figure.dance"; case .ballet: return "sparkles"; case .house: return "opticaldisc"
        }
    }
}

enum PartyRoomType: String, CaseIterable, Identifiable {
    case voice = "Voice party", video = "Video party"
    var id: String { rawValue }
}
enum PartyCardAppearance { case standard, accent }
struct PartyParticipant: Identifiable {
    let id: String
    let asset: String?
    let name: String
}
struct PartyPopularity {
    let value: Int
    let label: String
}
struct PartyRoom: Identifiable, Hashable {
    let id: String
    var title: String
    var description: String
    var type: PartyRoomType
    var category: PartyCategory
    var appearance: PartyCardAppearance = .standard
    var tag: String? = nil
    var participants: [PartyParticipant] = []
    var popularity: PartyPopularity? = nil
    var onlineCount: Int? = nil
    var draftID: UUID? = nil
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
struct PartyFilter: Equatable {
    enum Kind: String, CaseIterable, Identifiable {
        case all = "All rooms", voice = "Voice", video = "Video"
        var id: String { rawValue }
    }
    var kind: Kind = .all
    var popularFirst = false
    var isActive: Bool { kind != .all || popularFirst }
    func includes(_ room: PartyRoom) -> Bool {
        kind == .all || (kind == .voice && room.type == .voice) || (kind == .video && room.type == .video)
    }
}

enum PartyTool: String, Identifiable {
    case mood, cards, orbit
    var id: String { rawValue }
    var title: String {
        switch self { case .mood: return "Dance mood"; case .cards: return "Conversation cards"; case .orbit: return "Dance circle" }
    }
}

/// Authored membership rosters, not a presence response from a voice service.
/// Every dancer has one portrait, and that portrait is not reused for anyone else.
enum DancePartyCatalog {
    private static let names: [[String]] = [
        ["Maya", "Luca", "Elena", "Owen"],
        ["Emma", "Jay", "Priya", "Lucas", "Nina", "Theo"],
        ["Sofia", "Marcus", "Isla"],
        ["Aria", "Noah", "Zoe", "Finn", "Ivy"],
        ["Chloe", "Ethan", "Ruby", "Adam", "Leah", "Oscar", "Mila", "Alex"],
        ["Grace", "Oliver", "Ella", "Jude"],
        ["Freya", "Leo", "Alice", "Hugo", "Lily", "Max", "Eva"],
        ["Hazel", "James", "Rose", "Daniel", "Lucy", "Felix", "Clara", "Ben", "Mabel", "Cole"]
    ]
    private static func people(_ index: Int) -> [PartyParticipant] {
        names[index].enumerated().map { offset, name in
            PartyParticipant(id: "dancer-\(index)-\(offset)", asset: DancerPortraits.asset(forName: name), name: name)
        }
    }
    private static func room(_ id: String, _ title: String, _ description: String, _ category: PartyCategory,
                             _ index: Int, type: PartyRoomType = .voice, accent: Bool = false, tag: String? = nil) -> PartyRoom {
        let participants = people(index)
        return PartyRoom(id: id, title: title, description: description, type: type, category: category,
            appearance: accent ? .accent : .standard, tag: tag, participants: participants,
            popularity: .init(value: participants.count * 3, label: "\(participants.count * 3)"), onlineCount: participants.count)
    }
    static let rooms: [PartyRoom] = [
        room("hip-hop-crew", "Hip Hop Vibes", "Trade grooves, warm-up tracks and practice goals with people who love hip-hop.", .hipHop, 0),
        room("k-pop-combo", "K-Pop Practice", "Break a favorite chorus into eight-counts and talk through the tricky transitions.", .kPop, 1, accent: true, tag: "Dance talk"),
        room("jazz-afterhours", "Jazz Flow", "A space for jazz technique, expression and the little wins from class.", .jazz, 2),
        room("freestyle-circle", "Freestyle Circle", "Explore musicality, textures and the freedom of freestyle.", .freestyle, 3, accent: true),
        room("dance-camera", "Studio Sessions", "Talk about filming routines, framing footwork and sharing your progress.", .hipHop, 4, type: .video),
        room("ballet-circle", "Ballet Flow", "Compare practice notes, favorite variations and ways to stay inspired.", .ballet, 5),
        room("house-friends", "House Flow", "Connect over footwork, jacking and the tracks that get you moving.", .house, 6, tag: "Meet dancers"),
        room("practice-break", "Dance Break", "Swap freestyle ideas and celebrate a few minutes of movement.", .freestyle, 7, type: .video)
    ]
    static func room(from draft: VoiceRoomDraft) -> PartyRoom {
        PartyRoom(id: draft.id.uuidString, title: draft.title, description: draft.description,
                  type: draft.partyType.flatMap(PartyRoomType.init(rawValue:)) ?? .voice,
                  category: draft.danceCategory.flatMap(PartyCategory.init(rawValue:)) ?? .freestyle,
                  draftID: draft.id)
    }
}
