import Foundation

/// Authored frontend conversation content, not posts fetched from real accounts.
/// Per-video ordering is repeatable; views never regenerate IDs during rendering.
enum DanceDiscussionContent {
    struct Line {
        let name: String
        let text: String
        let avatarAsset: String
    }

    static let phrases = [
        "I watched the feet first, then noticed all the little shoulder details.",
        "Could you break this down into two eight-counts?",
        "The last transition is the part I keep coming back to.",
        "This would be such a fun combo to learn with friends.",
        "Trying this after class. Wish my coordination luck!",
        "The movement feels relaxed without losing the rhythm.",
        "How long did it take to get comfortable with this sequence?",
        "I love that you leave space between the accents.",
        "That change of direction caught me off guard in the best way.",
        "My brain gets it. My feet need a few more tries.",
        "A slower version would help so much with the transitions.",
        "The tiny details make the whole routine feel personal.",
        "Anyone else learning the arms and feet separately?",
        "Adding this to my weekend practice ideas.",
        "I was counting along and lost count because I was enjoying it.",
        "The confidence here is what I want to work on next.",
        "What do you focus on first: timing or shapes?",
        "This made me get out of my chair for a minute.",
        "I like how the movement carries through the quiet moments.",
        "That little reset before the next phrase is lovely.",
        "Would love to see another take with a different groove.",
        "I always rush that kind of transition. This is a good reminder.",
        "The ending flows right back into the beginning.",
        "Such a nice balance of control and freedom.",
        "I needed some practice motivation today. Found it.",
        "Do you count this in your head or follow the melody?",
        "This has that one-more-watch feeling.",
        "The energy stays consistent all the way through.",
        "A simple step with a little personality goes a long way.",
        "I tried marking this slowly and it finally started making sense.",
        "Your upper body and footwork tell the same story.",
        "Not me practicing the first bit in my kitchen.",
        "I'd love a closer view of the foot placement.",
        "The soft moments are just as interesting as the sharp ones.",
        "This is the kind of session that makes practice feel fun.",
        "Which part did you find hardest to learn?",
        "I appreciate seeing movement that has room to breathe.",
        "The way you connect each phrase is really satisfying.",
        "Trying to get that same ease without overthinking every step.",
        "A good reminder to look up instead of watching my feet.",
        "I can imagine a whole crew doing their own version of this.",
        "The groove is doing a lot of the storytelling here.",
        "That small pause gives the next movement so much impact.",
        "My favorite part is the change in texture halfway through.",
        "Would you teach this in a beginner class?",
        "This feels like a conversation with the music.",
        "Keeping this in mind for my next freestyle session.",
        "I love a routine you can make your own.",
        "Practice goal: finish the movement instead of rushing ahead.",
        "That last phrase deserves another round.",
        "The rhythm is clear even when the movement gets smaller.",
        "I want to try this with my dance partner.",
        "Such a good example of making the basics feel fresh.",
        "I keep noticing something new each time.",
        "What would you call the step in the middle?",
        "The control in those direction changes is impressive.",
        "This is going on my next practice playlist.",
        "It looks like you are really enjoying the movement.",
        "Taking a little inspiration from this for class tomorrow.",
        "A little less tension and a lot more groove. Love it."
    ]

    private static func stableSeed(for id: UUID) -> UInt64 {
        id.uuidString.utf8.reduce(UInt64(14695981039346656037)) {
            ($0 ^ UInt64($1)) &* 1099511628211
        }
    }

    static func commentCount(for id: UUID) -> Int { 14 + Int(stableSeed(for: id) % 9) }

    static func lines(for video: LocalVideo) -> [Line] {
        let seed = stableSeed(for: video.id)
        var generator = ConversationRandom(state: seed)
        var general = phrases.shuffled(using: &generator)
        let tag = (video.bundledClip?.assetName ?? "").lowercased()
        var specific: [String] = []
        if tag.contains("ballet"), tag != "dance-ballet-class" {
            specific = ["The way you carry the arms makes the phrase feel so light.", "Working on balance is teaching me a lot of patience.", "I'd love to hear how you warm up before ballet practice.", "Those extended lines give the movement such a calm feeling."]
        } else if tag.contains("contemporary") || tag.contains("expressive") || tag == "dance-ballet-class" {
            specific = ["The reach through the fingertips adds so much expression.", "I like how the movement grows instead of stopping at each shape.", "Contemporary always reminds me to use the whole space.", "How do you choose where to soften a movement?"]
        } else if tag.contains("salsa") || tag.contains("shared") || tag.contains("partner") || tag.contains("duet") {
            specific = ["Moving together without losing your own style is such a skill.", "Partner practice makes timing feel like a conversation.", "Would love to learn this with a friend.", "The shared rhythm makes this so enjoyable to watch."]
        } else if tag.contains("street") || tag.contains("hiphop") || tag.contains("crew") || tag.contains("footwork") {
            specific = ["The grounded groove makes the footwork stand out.", "I need to work on keeping my shoulders loose like that.", "Love seeing different textures in street dance.", "That weight shift is the detail I want to practice."]
        }
        specific.shuffle(using: &generator)
        general = Array(specific.prefix(3)) + general
        let names = ["Emma", "Jay", "Sofia", "Marcus", "Chloe", "Daniel", "Maya", "Alex",
                     "Lena", "Noah", "Riley", "Oliver", "Nina", "Ethan", "Grace", "Lucas",
                     "Zoe", "Theo", "Ruby", "Leo", "Eva", "Finn", "Aria", "Miles"]
        let people = names.indices.shuffled(using: &generator)
        let count = commentCount(for: video.id)
        return general.prefix(count).enumerated().map { index, text in
            let person = people[index % people.count]
            return Line(name: names[person], text: text, avatarAsset: DancerPortraits.asset(forName: names[person]))
        }
    }

    private struct ConversationRandom: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E3779B97F4A7C15
            var value = state
            value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
            value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
            return value ^ (value >> 31)
        }
    }
}
