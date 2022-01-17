import Foundation
import FigmaKit
import UIKit

final class FileController {
    private let figmaID: String
    private let cache: URLCache
    private let googleFonts: GoogleFontRetriever
    init(figmaID: String, cache: URLCache, googleFonts: GoogleFontRetriever) {
        self.figmaID = figmaID
        self.cache = cache
        self.googleFonts = googleFonts
        
        self.fileVC = FileViewController(googleFonts: googleFonts)
        self.navVC = UINavigationController(rootViewController: fileVC)
        
        fileVC.title = "Loading..."
        
        load()
    }
    
    deinit {
        fileTask?.cancel()
        imageFillsTask?.cancel()
    }
    
    // In-memory structured representation of the Figma file.
    private var file: FigmaKit.File?
    
    // UI elements
    private let fileVC: FileViewController
    private let navVC: UINavigationController
    
    // Loading the file
    func load() {
        loadFile()
        loadImageFills()
    }
    
    private var fileTask: URLSessionDataTask?
    private func loadFile() {
        fileTask?.cancel()
        fileTask = nil
        
        print("Fetching file...")
        let url = URL(string: "https://api.figma.com/v1/files/\(figmaID)?geometry=paths")!
        var request = URLRequest(url: url)
        request.addValue(Config.figmaToken, forHTTPHeaderField: "X-FIGMA-TOKEN")
        if let response = cache.cachedResponse(for: request) {
            print("Loaded from cache.")
            DispatchQueue.global(qos: .userInitiated).async {
                self.fileDidLoad(data: response.data, response: response.response, error: nil)
            }
        }
        // TODO: Always fetch, even if we can load from cache. This is being else'd out only to reduce excessive server load during development.
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            if let response = response,
               let data = data {
                self.cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            }
            self.fileDidLoad(data: data, response: response, error: error)
        }
        self.fileTask = task
        task.resume()
    }
    
    private var imageFillsTask: URLSessionDataTask?
    private func loadImageFills() {
        print("Loaded image fills...")
        imageFillsTask?.cancel()
        imageFillsTask = nil
        
        let url = URL(string: "https://api.figma.com/v1/files/\(figmaID)/images")!
        var request = URLRequest(url: url)
        request.addValue(Config.figmaToken, forHTTPHeaderField: "X-FIGMA-TOKEN")
        if let response = cache.cachedResponse(for: request) {
            print("Loaded image fills from cache.")
            DispatchQueue.global(qos: .userInitiated).async {
                self.imageFillsDidLoad(data: response.data, response: response.response, error: nil)
            }
        } else {
            print("Loaded image fills from network.")
            // TODO: Always fetch, even if we can load from cache. This is being else'd out only to reduce excessive server load during development.
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else {
                    return
                }
                if let response = response,
                   let data = data {
                    self.cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
                }
                self.imageFillsDidLoad(data: data, response: response, error: error)
            }
            self.imageFillsTask = task
            task.resume()
        }
    }
    
    var closeItem: UIBarButtonItem? {
        get { return fileVC.navigationItem.leftBarButtonItem }
        set { fileVC.navigationItem.leftBarButtonItem = newValue }
    }
    var viewController: UIViewController {
        return navVC
    }
}

// MARK: - Loading files from network and disk
extension FileController {
    func fileDidLoad(data: Data?, response: URLResponse?, error: Error?) -> Void {
        print("Decoding file...")
        assert(!Thread.isMainThread, "This method is expected to be ran on a background thread to avoid locking the UI")
        
        guard let data = data else { return }
        let decoder = JSONDecoder()
        do {
            let file = try decoder.decode(FigmaKit.File.self, from: data)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.fileVC.file = file
                self.fileVC.title = file.name
                self.file = file
            }
        } catch let error {
            print("Failed to decode file: \(error)")
        }
        if data.count < 1024 * 1024 * 2 {
            print(String(data: data, encoding: .utf8)!)
        }
    }
    
    private struct ImageFillsResponse: Codable {
        let error: Bool
        let status: Int
        let meta: Meta
        
        struct Meta: Codable {
            let images: [String: String]
        }
    }
    
    func imageFillsDidLoad(data: Data?, response: URLResponse?, error: Error?) -> Void {
        print("Decoding image fills...")
        assert(!Thread.isMainThread, "This method is expected to be ran on a background thread to avoid locking the UI")
        
        guard let data = data else { return }
        let decoder = JSONDecoder()
        do {
            let fills = try decoder.decode(ImageFillsResponse.self, from: data)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.fileVC.imageFills = fills.meta.images
            }
        } catch let error {
            print("Failed to decode image fills: \(error)")
        }
    }
}

// fofjfjffjfjfjfjfjfjfjfjfjfjfjjfjfjfjfjfjfj
