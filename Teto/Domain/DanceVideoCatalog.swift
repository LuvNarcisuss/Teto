import Foundation

enum DanceSurface {
    case live, shorts, phrase
}

/// Licensed dance films; the source archive is outside the runtime bundle.
/// Phrases also exposes each film's attribution and license in Film credits.
/// Each clip belongs to one surface: Live, Shorts, or Phrases.
struct DanceVideo {
    let id: UUID
    let title: String
    let creator: String
    let assetName: String
    let duration: Double
    var surface: DanceSurface = .live
    let sourceURL: URL
    var collectionGeneration = 0

    var localVideo: LocalVideo {
        LocalVideo(id: id, title: title, fileExtension: "mp4", duration: duration,
                   importedAt: Date(timeIntervalSince1970: 0), isSaved: false, isDance: true)
    }

    func resourceURL(fileExtension: String) -> URL {
        Bundle.main.url(forResource: assetName, withExtension: fileExtension)
            ?? Bundle.main.bundleURL.appendingPathComponent("\(assetName).\(fileExtension)")
    }
}

enum DanceVideoCatalog {
    /// Build once per app session, never during view updates.
    static func shuffledDiscoveryIDs(for surface: DanceSurface) -> [UUID] {
        let groups = Dictionary(grouping: entries.filter { $0.surface == surface }, by: \.collectionGeneration)
        return groups.keys.sorted(by: >).flatMap { generation in
            (groups[generation] ?? []).shuffled().map(\.id)
        }
    }

    static let entries: [DanceVideo] = [
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007677198")!,
                   title: "Find your rhythm", creator: "Ivan S", assetName: "dance-studio", duration: 14.16, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/woman-recording-herself-dancing-7677198/")!),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008713941")!,
                   title: "Freestyle by the sea", creator: "Kampus Production", assetName: "dance-seaside", duration: 19.96,
                   sourceURL: URL(string: "https://www.pexels.com/video/woman-dancing-by-the-sea-8713941/")!),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007958175")!,
                   title: "Hip hop in motion", creator: "cottonbro studio", assetName: "dance-hiphop-solo", duration: 40.72,
                   sourceURL: URL(string: "https://www.pexels.com/video/a-young-man-dancing-to-hip-hop-music-7958175/")!, collectionGeneration: 1),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008688877")!,
                   title: "Crew rhythm", creator: "ANTONI SHKRABA production", assetName: "dance-crew-rhythm", duration: 11.44, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/people-dancing-hip-hop-8688877/")!, collectionGeneration: 1),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000003873100")!,
                   title: "Own the eight-count", creator: "Polina Tankilevitch", assetName: "dance-white-studio", duration: 3.92,
                   sourceURL: URL(string: "https://www.pexels.com/video/a-young-woman-dancing-hip-hop-3873100/")!, collectionGeneration: 1),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000010264814")!,
                   title: "Move together", creator: "cottonbro studio", assetName: "dance-hiphop-duet", duration: 10.24,
                   sourceURL: URL(string: "https://www.pexels.com/video/two-women-dancing-hip-hop-10264814/")!, collectionGeneration: 1),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008462487")!,
                   title: "Partnered lines", creator: "MART PRODUCTION", assetName: "dance-ballet-duet", duration: 23.68, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/man-and-woman-dancing-ballet-8462487/")!, collectionGeneration: 1),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008956471")!,
                   title: "Studio joy", creator: "Kampus Production", assetName: "dance-studio-joy", duration: 22.48,
                   sourceURL: URL(string: "https://www.pexels.com/video/a-woman-dancing-in-a-studio-8956471/")!, collectionGeneration: 1),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007480483")!,
                   title: "Practice partners", creator: "MART PRODUCTION", assetName: "dance-practice-partners", duration: 15.04, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/man-and-woman-dancing-together-7480483/")!, collectionGeneration: 1),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000005805069")!,
                   title: "After-dark groove", creator: "Tima Miroshnichenko", assetName: "dance-purple-groove", duration: 10.64, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/vertical-video-of-a-woman-dancing-5805069/")!, collectionGeneration: 1),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007571002")!,
                   title: "Contemporary flow", creator: "Antoni Shkraba", assetName: "dance-contemporary-flow", duration: 28.84, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/woman-dancing-in-a-studio-7571002/")!, collectionGeneration: 1),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007322867")!,
                   title: "Contemporary floorwork", creator: "MART PRODUCTION", assetName: "dance-ballet-class", duration: 19.6, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/ballerinas-dancing-on-a-dance-studio-7322867/")!, collectionGeneration: 1),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008027525")!,
                   title: "Urban footwork", creator: "Yaroslav Shuraev", assetName: "dance-urban-footwork", duration: 50.04, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/woman-doing-breakdance-8027525/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000005362370")!,
                   title: "Street power", creator: "Allan Mas", assetName: "dance-street-power", duration: 6.2,
                   sourceURL: URL(string: "https://www.pexels.com/video/young-guy-doing-break-dance-on-the-street-5362370/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008715155")!,
                   title: "Under the bridge", creator: "Kampus Production", assetName: "dance-bridge-freestyle", duration: 24.0,
                   sourceURL: URL(string: "https://www.pexels.com/video/a-woman-doing-break-dance-on-the-street-8715155/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000006548168")!,
                   title: "Court session", creator: "Marc Espejo", assetName: "dance-court-session", duration: 35.375,
                   sourceURL: URL(string: "https://www.pexels.com/video/a-man-dancing-6548168/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000031889677")!,
                   title: "Studio chemistry", creator: "Shuttercraftsman", assetName: "dance-studio-chemistry", duration: 17.76, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/dynamic-dance-routine-in-modern-studio-setting-31889677/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008956295")!,
                   title: "Together on the beat", creator: "Kampus Production", assetName: "dance-group-rehearsal", duration: 23.24,
                   sourceURL: URL(string: "https://www.pexels.com/video/women-dancing-in-the-studio-8956295/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000006939884")!,
                   title: "Follow the feeling", creator: "Pavel Danilyuk", assetName: "dance-expressive-arms", duration: 52.218833,
                   sourceURL: URL(string: "https://www.pexels.com/video/a-woman-dancing-in-the-dance-studio-6939884/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007689096")!,
                   title: "A shared rhythm", creator: "KoolShooters", assetName: "dance-shared-rhythm", duration: 12.8,
                   sourceURL: URL(string: "https://www.pexels.com/video/couple-dancing-together-7689096/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008249922")!,
                   title: "Salsa in the sunshine", creator: "RDNE Stock project", assetName: "dance-sunny-salsa", duration: 10.72, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/woman-wearing-floral-dress-dancing-with-a-man-8249922/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000006834067")!,
                   title: "Glitter and groove", creator: "Mikhail Nilov", assetName: "dance-glitter-groove", duration: 23.72, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/a-woman-dancing-in-the-studio-6834067/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000005138501")!,
                   title: "Ballet practice", creator: "Budgeron Bach", assetName: "dance-ballet-practice", duration: 9.32,
                   sourceURL: URL(string: "https://www.pexels.com/video/a-ballet-class-going-on-in-a-dance-studio-5138501/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000005561275")!,
                   title: "Street crew energy", creator: "Tima Miroshnichenko", assetName: "dance-street-crew", duration: 9.64, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/people-dancing-outdoors-5561275/")!, collectionGeneration: 2),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000002795746")!,
                   title: "Rooftop freestyle", creator: "cottonbro studio", assetName: "dance-rooftop-freestyle", duration: 20.4, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/hip-hop-dancing-2795746/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000004734692")!,
                   title: "Crosswalk session", creator: "cottonbro studio", assetName: "dance-crosswalk-duet", duration: 37.8, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/a-man-and-woman-are-standing-on-a-street-4734692/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008027892")!,
                   title: "Bucket hat groove", creator: "Yaroslav Shuraev", assetName: "dance-bucket-groove", duration: 20.84, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/woman-doing-hiphop-dance-8027892/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008688884")!,
                   title: "Night crew", creator: "ANTONI SHKRABA production", assetName: "dance-night-crew", duration: 14.22, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/stylish-woman-dancing-8688884/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000013521639")!,
                   title: "Street tango", creator: "Sol Pinto", assetName: "dance-street-tango", duration: 26.4264, surface: .shorts,
                   sourceURL: URL(string: "https://www.pexels.com/video/dancing-tango-on-city-street-13521639/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000010264579")!,
                   title: "Loft session", creator: "cottonbro studio", assetName: "dance-loft-session", duration: 21.24, surface: .live,
                   sourceURL: URL(string: "https://www.pexels.com/video/woman-dancing-in-hip-hop-style-10264579/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000010264810")!,
                   title: "Loft partners", creator: "cottonbro studio", assetName: "dance-loft-partners", duration: 27.32, surface: .live,
                   sourceURL: URL(string: "https://www.pexels.com/video/two-women-dancing-hip-hop-style-10264810/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000019851286")!,
                   title: "Salsa floor", creator: "E CG", assetName: "dance-salsa-floor", duration: 17.142, surface: .live,
                   sourceURL: URL(string: "https://www.pexels.com/video/salsa-colorful-shoes-19851286/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000003873074")!,
                   title: "Three and a count", creator: "Polina Tankilevitch", assetName: "dance-trio-count", duration: 4.8, surface: .live,
                   sourceURL: URL(string: "https://www.pexels.com/video/young-women-dancing-3873074/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000006939802")!,
                   title: "Lifted arms", creator: "Pavel Danilyuk", assetName: "dance-lifted-arms", duration: 38.7387, surface: .live,
                   sourceURL: URL(string: "https://www.pexels.com/video/dancers-practicing-in-the-studio-6939802/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007324086")!,
                   title: "Warm room", creator: "KoolShooters", assetName: "dance-warm-room", duration: 20.52, surface: .live,
                   sourceURL: URL(string: "https://www.pexels.com/video/women-dancing-in-a-studio-7324086/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007405378")!,
                   title: "Cypher night", creator: "Ekaterina Antipova", assetName: "dance-cypher-night", duration: 13.96, surface: .live,
                   sourceURL: URL(string: "https://www.pexels.com/video/woman-hip-hop-dance-7405378/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007569650")!,
                   title: "Hoodie phrase", creator: "Antoni Shkraba", assetName: "dance-hoodie-phrase", duration: 9.44, surface: .live,
                   sourceURL: URL(string: "https://www.pexels.com/video/people-dancing-in-the-studio-7569650/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007667010")!,
                   title: "Mural phrase", creator: "ArtHouse Studio", assetName: "dance-mural-phrase", duration: 18.958333, surface: .live,
                   sourceURL: URL(string: "https://www.pexels.com/video/female-performers-dancing-in-studio-7667010/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008249626")!,
                   title: "Mosaic steps", creator: "RDNE Stock project", assetName: "dance-mosaic-steps", duration: 12.4, surface: .live,
                   sourceURL: URL(string: "https://www.pexels.com/video/a-man-and-a-woman-dancing-beside-mosaic-artwork-8249626/")!, collectionGeneration: 3),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000026861347")!,
                   title: "Two-step flow", creator: "VincaniTV", assetName: "phrase-film-hiphop", duration: 336.669667, surface: .phrase,
                   sourceURL: URL(string: "https://www.youtube.com/watch?v=tODVnrFX9yM")!),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008853874")!,
                   title: "Reach and turn", creator: "Jenny Coogan; Robin Jung", assetName: "phrase-film-reach", duration: 26.773292, surface: .phrase,
                   sourceURL: URL(string: "https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2018.02371/full")!),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008956001")!,
                   title: "Balboa basics", creator: "Lainey Silver", assetName: "phrase-film-rehearsal", duration: 202.919002, surface: .phrase,
                   sourceURL: URL(string: "https://www.youtube.com/watch?v=l-avoQVmi3g")!),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008955994")!,
                   title: "Farmer footwork", creator: "Streetz Ahead", assetName: "phrase-film-groove", duration: 145.011000, surface: .phrase,
                   sourceURL: URL(string: "https://www.youtube.com/watch?v=jJXQ1Wj1ERY")!),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000032097114")!,
                   title: "Six-step circle", creator: "Neil Sweeney", assetName: "phrase-film-street", duration: 66.966900, surface: .phrase,
                   sourceURL: URL(string: "https://commons.wikimedia.org/wiki/File:Tutorial_breakdance_-_Six_Step.webm")!),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000007322798")!,
                   title: "Waltz walkthrough", creator: "Vina Castelli", assetName: "phrase-film-ballet", duration: 755.390998, surface: .phrase,
                   sourceURL: URL(string: "https://www.youtube.com/watch?v=zA7VcfzwAyI")!),
        DanceVideo(id: UUID(uuidString: "AC8365F1-44DC-4BF4-934D-000008955363")!,
                   title: "Solo Charleston", creator: "GoldMinka", assetName: "phrase-film-jazz", duration: 411.000000, surface: .phrase,
                   sourceURL: URL(string: "https://www.youtube.com/watch?v=_a_0IYm1weQ")!),
    ]
}
