import CryptoKit
import Foundation

struct AgreementAcceptance: Codable {
    let version: String
    let acceptedAt: Date
}

enum AgreementDocument: String, Identifiable, CaseIterable {
    case terms = "TermsOfService"
    case privacy = "PrivacyPolicy"
    var id: String { rawValue }
    var title: String { self == .terms ? "Teto - Terms of Service" : "Teto - Privacy Policy" }
    var onlineURL: URL {
        switch self {
        case .terms:
            return URL(string: "https://docs.google.com/document/d/1PBHnF3UNjCBkEuzOyETCUOWgMEz4eiPfGj_PooGJM4c")!
        case .privacy:
            return URL(string: "https://docs.google.com/document/d/1BGNLMpwOFa8_6Fz3S4zv9xkKELYTBEx3KXi3DLVBSj0")!
        }
    }
    var fileURL: URL? {
        Bundle.main.url(forResource: rawValue, withExtension: "html", subdirectory: "Agreements")
    }
}

enum TetoUserAgreement {
    // Acceptance refers to the exact bundled files rather than the retired inline copy.
    static let version: String = {
        var content = Data()
        for document in AgreementDocument.allCases {
            guard let url = document.fileURL, let bytes = try? Data(contentsOf: url) else {
                return "unavailable"
            }
            content.append(contentsOf: document.rawValue.utf8)
            content.append(0)
            content.append(bytes)
        }
        let digest = SHA256.hash(data: content).map { String(format: "%02x", $0) }.joined()
        return "local-" + String(digest.prefix(12))
    }()
}
