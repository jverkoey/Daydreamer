import Foundation

extension GoogleFonts {
    struct WebfontList: Codable {
        let kind: String
        let items: [Webfont]
    }

    struct Webfont: Codable {
        let kind: String
        let family: String
        let variants: [String]
        let subsets: [String]
        let version: String
        let lastModified: String
        let files: [String: String]
    }
}
