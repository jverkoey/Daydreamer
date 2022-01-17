import FigmaKit
import UIKit

final class FileViewController: UIViewController {
    var file: FigmaKit.File? {
        get { return canvasViewController.file }
        set { canvasViewController.file = newValue}
    }
    var imageFills: [String: String]? {
        get { return canvasViewController.imageFills }
        set { canvasViewController.imageFills = newValue}
    }
    
    private let canvasViewController: CanvasViewController
    private let layersViewController: LayersViewController
    
    init(googleFonts: GoogleFontRetriever) {
        canvasViewController = CanvasViewController(googleFonts: googleFonts)
        layersViewController = LayersViewController()
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(canvasViewController)
        addChild(layersViewController)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        canvasViewController.view.translatesAutoresizingMaskIntoConstraints = false
        layersViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasViewController.view)
        view.addSubview(layersViewController.view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: layersViewController.view.topAnchor),
            view.topAnchor.constraint(equalTo: canvasViewController.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: layersViewController.view.bottomAnchor),
            view.bottomAnchor.constraint(equalTo: canvasViewController.view.bottomAnchor),
            
            view.leadingAnchor.constraint(equalTo: layersViewController.view.leadingAnchor),
            layersViewController.view.widthAnchor.constraint(equalToConstant: 300),
            canvasViewController.view.leadingAnchor.constraint(equalTo: layersViewController.view.trailingAnchor),
            view.trailingAnchor.constraint(equalTo: canvasViewController.view.trailingAnchor),
        ])
        
        canvasViewController.didMove(toParent: self)
        layersViewController.didMove(toParent: self)
    }
}
