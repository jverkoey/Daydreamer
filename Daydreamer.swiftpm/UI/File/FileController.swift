import Foundation
import FigmaKit
import UIKit

final class FileController {
    private let figmaID: String
    init(figmaID: String) {
        self.figmaID = figmaID
        self.canvasVC = CanvasViewController()
        self.navVC = UINavigationController(rootViewController: canvasVC)
        
        canvasVC.title = "Loading..."
        
        load()
    }
    
    // In-memory structured representation of the Figma file.
    private var file: FigmaKit.File?
    
    // UI elements
    private let canvasVC: CanvasViewController
    private let navVC: UINavigationController
    
    // Loading the file
    private var fileTask: URLSessionDataTask?
    private let cache = URLCache(memoryCapacity: .max, diskCapacity: .max, directory: nil)
    func load() {
        fileTask?.cancel()
        fileTask = nil
        
        let url = URL(string: "https://api.figma.com/v1/files/\(figmaID)?geometry=paths")!
        var request = URLRequest(url: url)
        request.addValue(Config.figmaToken, forHTTPHeaderField: "X-FIGMA-TOKEN")
        if let response = cache.cachedResponse(for: request) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.fileDidLoad(data: response.data, response: response.response, error: nil)
            }
        } else {
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
    }
    
    var closeItem: UIBarButtonItem? {
        get { return canvasVC.navigationItem.leftBarButtonItem }
        set { canvasVC.navigationItem.leftBarButtonItem = newValue }
    }
    var viewController: UIViewController {
        return navVC
    }
}

// MARK: - Loading files from network and disk
extension FileController {
    func fileDidLoad(data: Data?, response: URLResponse?, error: Error?) -> Void {
        assert(!Thread.isMainThread, "This method is expected to be ran on a background thread to avoid locking the UI")
        
        guard let data = data else { return }
        let decoder = JSONDecoder()
        guard let file = try? decoder.decode(FigmaKit.File.self, from: data) else {
            print("Failed to decode file")
            print(String(data: data, encoding: .utf8)!)
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.canvasVC.file = file
            self.file = file
        }
    }
}
