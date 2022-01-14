import CoreText
import Foundation
import UIKit

protocol GoogleFontRetriever {
    @MainActor
    func font(family: String, weight: Int, italic: Bool, didLoad: @escaping (UIFont) -> Void)
}

final class GoogleFonts {
    init(cache: URLCache) {
        self.cache = cache
    }
    
    @MainActor fileprivate var list: [Webfont]?
    private let cache: URLCache
    
    @MainActor
    func loadFonts() {
        let url = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?key=\(Config.googleFontsAPIKey)")!
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else {
                return
            }
            self.listDidLoad(data: data, response: response, error: error)
        }
        task.resume()
    }
    
    private func listDidLoad(data: Data?, response: URLResponse?, error: Error?) -> Void {
        assert(!Thread.isMainThread, "This method is expected to be ran on a background thread to avoid locking the UI")
        
        guard let data = data else { return }
        let decoder = JSONDecoder()
        do {
            let list = try decoder.decode(WebfontList.self, from: data)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.list = list.items
                
                // Reset the mapping of requests to URLs now that the list may have changed.
                self.requestToURL.removeAll()
                
                for request in self.requestQueue.keys {
                    self.startDeferredRequestIfPossible(request)
                }
            }
        } catch let error {
            print("Failed to decode Google Fonts list: \(error)")
        }
    }
    
    fileprivate struct FontRequest: Hashable {
        let fontFamily: String
        let weight: Int
        let italic: Bool
    }
    @MainActor
    fileprivate var requestQueue: [FontRequest: [(UIFont) -> Void]] = [:]
    
    @MainActor
    fileprivate var requestToURL: [FontRequest: URL] = [:]
    
    @MainActor
    fileprivate var urlToTask: [URL: URLSessionDataTask] = [:]
    @MainActor
    fileprivate var requestToFont: [FontRequest: UIFont] = [:]
}

private let systemFonts = Set<String>([
    "SF Mono",
    "SF Pro",
    "SF Pro Display",
    "SF Pro Text",
])

extension GoogleFonts: GoogleFontRetriever {
    @MainActor
    func font(family: String, weight: Int, italic: Bool = false, didLoad: @escaping (UIFont) -> Void) {
        let request = FontRequest(fontFamily: family, weight: weight, italic: italic)
        if systemFonts.contains(family) {
            instantiateFont(forRequest: request)
        }
        if let font = requestToFont[request] {
            // Happy path; font's already loaded in memory. Return it!
            didLoad(font)
            return
        }
        
        // We're going to need to request this font then. Add it to the queue.
        requestQueue[request, default: []].append(didLoad)
        
        // We haven't fully loaded the font yet, but maybe we have a version stored on disk already?
        let path = pathForRequest(request)
        if FileManager.default.fileExists(atPath: path.path) {
            DispatchQueue.global(qos: .background).async {
                self.registerFont(forRequest: request)
            }
        }
        startDeferredRequestIfPossible(request)
    }
    
    fileprivate func resolve(_ request: FontRequest, list: [Webfont]) {
        assert(!Thread.isMainThread, "This method is expected to be ran on a background thread to avoid locking the UI")
        
        let fontFileKey: String
        if request.weight == 400 {
            if request.italic {
                fontFileKey = "italic"
            } else {
                fontFileKey = "regular"
            }
        } else {
            fontFileKey = request.weight.description + (request.italic ? "italic" : "")
        }
        // First, find the URL for the font.
        let candidateFamilies: [Webfont] = list.filter({ font in
            return font.family.lowercased() == request.fontFamily.lowercased()
        })
        let urls: [String] = candidateFamilies.compactMap({ font in
            return font.files[fontFileKey]
        })
        guard !urls.isEmpty else {
            print("No urls found for font request: \(request)")
            print(candidateFamilies)
            return
        }
        guard urls.count == 1 else {
            print("Ambiguous url resolution for: \(request)")
            print(urls)
            return
        }
        assert(urls.count == 1, "Expected exactly one url to be found.")
        guard let url = URL(string: urls[0]) else {
            print("Failed to create url from \(urls[0])")
            return
        }
        
        downloadFont(url, forRequest: request)
        
        DispatchQueue.main.async {
            // Cache this URL so that we don't need to find it again.
            self.requestToURL[request] = url
        }
    }
    
    fileprivate func pathForRequest(_ request: FontRequest) -> URL {
        return documentsDirectory()
            .appendingPathComponent("fonts")
            .appendingPathComponent(request.fontFamily)
            .appendingPathComponent(request.weight.description)
            .appendingPathComponent(request.italic ? "italic" : "regular")
            .appendingPathExtension("ttf")
    }
    
    @MainActor
    fileprivate func instantiateFont(forRequest request: FontRequest) {
        let font: UIFont
        if systemFonts.contains(request.fontFamily) {
            // We need to load system fonts via the system fonts APIs.
            if request.italic {
                font = .italicSystemFont(ofSize: 20)
            } else if request.fontFamily == "SF Mono" {
                font = .monospacedSystemFont(ofSize: 20, weight: weightMap[request.weight] ?? .regular)
            } else {
                font = .systemFont(ofSize: 20, weight: weightMap[request.weight] ?? .regular)
            }
        } else {
            var traits: [UIFontDescriptor.TraitKey: Any] = [
                .weight: weightMap[request.weight] ?? .regular,
            ]
            if request.italic {
                traits[.symbolic] = UIFontDescriptor.SymbolicTraits.traitItalic.rawValue
            }
            let descriptor = UIFontDescriptor(fontAttributes: [
                .family: request.fontFamily,
                .traits: traits
            ])
            font = UIFont(descriptor: descriptor, size: 20)
        }
        self.requestToFont[request] = font
        
        if let callbacks = self.requestQueue[request] {
            for callback in callbacks {
                callback(font)
            }
        }
    }
    
    fileprivate func registerFont(forRequest request: FontRequest) {
        assert(!Thread.isMainThread, "This method is expected to be ran on a background thread to avoid locking the UI")
        
        let ttfPath = pathForRequest(request)
        var errorRef: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(ttfPath as CFURL, .process, &errorRef)
        if !success {
            if let errorRef = errorRef {
                let error = errorRef.takeRetainedValue() as Error as NSError
                if error.code == 105 {
                    // This error just signifies that the font was already registered, should be safe to ignore.
                } else {
                    return
                }
            } else {
                return
            }
        }
        DispatchQueue.main.async {
            self.instantiateFont(forRequest: request)
        }
    }

    fileprivate func downloadFont(_ url: URL, forRequest request: FontRequest) {
        assert(!Thread.isMainThread, "This method is expected to be ran on a background thread to avoid locking the UI")
        
        let ttfPath = pathForRequest(request)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to download font: \(error)")
            }
            guard let data = data else {
                return
            }
            try! FileManager.default.createDirectory(at: ttfPath.deletingLastPathComponent(), 
                                                     withIntermediateDirectories: true, 
                                                     attributes: nil)
            try! data.write(to: ttfPath)
            
            self.registerFont(forRequest: request)
            
            DispatchQueue.main.async {
                self.urlToTask.removeValue(forKey: url)
            }
        }
        DispatchQueue.main.sync {
            self.urlToTask[url] = task
        }
        task.resume()
    }
    
    @MainActor
    fileprivate func startDeferredRequestIfPossible(_ request: FontRequest) {
        guard let list = list else {
            return
        }
        // Ensure that we're always serving the most up-to-date font asset in a given app session.
        guard let url = requestToURL[request] else {
            DispatchQueue.global(qos: .background).async {
                self.resolve(request, list: list)
            }
            return
        }
        // We know the font's URL; have we already downloaded it?
        guard let font = requestToFont[request] else {
            DispatchQueue.global(qos: .background).async {
                self.downloadFont(url, forRequest: request)
            }
            return
        }
    
        guard let callbacks = requestQueue[request] else {
            return  // Nothing to do here.
        }
        for callback in callbacks {
            callback(font)
        }
        requestQueue[request]?.removeAll()
    }
}

private let weightMap: [Int: UIFont.Weight] = [
    100: .thin,
    200: .ultraLight,
    300: .light,
    400: .regular,
    500: .medium,
    600: .semibold,
    700: .bold,
    800: .heavy,
    900: .black
]

private func documentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

// fjfj
