import UIKit
import FigmaKit

final class CanvasViewController: UIViewController {
    var file: FigmaKit.File? {
        didSet {
            renderFile()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let gearImage = UIImage(systemName: "gear")
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: gearImage, style: .plain, target: self, action: #selector(showSettings))
        ]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let container = UIScrollView()
    private var canvas = UIView()
    private var boundingRect = CGRect.zero
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        container.frame = view.bounds
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.delegate = self
        container.minimumZoomScale = 0.01
        container.maximumZoomScale = 10.0
        view.addSubview(container)
    }
    
    @objc func showSettings() {
        print("Settings")
    }
}

extension CanvasViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
}

extension CanvasViewController {
    func renderFile() {
        guard let file = file else {
            return
        }
        title = file.name
        
        let page = file.document.children[0] as! FigmaKit.Node.Canvas
        
        container.backgroundColor = UIColor(figmaColor: page.backgroundColor)
        
        // TODO: Determine this based on the background color.
        container.indicatorStyle = .black
        
        // TODO: Ideally this performs a diff of the view hierarchy and only updates what's needed. For now, it's simpler to just throw everything away and rebuild but this *will* become a performance bottleneck.
        canvas.removeFromSuperview()
        canvas = UIView()
        container.addSubview(canvas)
        
        canvas.backgroundColor = container.backgroundColor
        
        let canvasMargins: CGFloat = 5000
        
        var boundingRect: CGRect? = nil
        for node in page.children {
            switch node {
            case let vector as FigmaKit.Node.Vector:
                let frame = CGRect(figmaRect: vector.absoluteBoundingBox)
                if let existingRect = boundingRect {
                    boundingRect = existingRect.union(frame)
                } else {
                    boundingRect = frame
                }
                
                let view: UIView
                if node is FigmaKit.Node.Rectangle {
                    view = UIView()
                    for fill in vector.fills {
                        switch fill {
                        case let solid as FigmaKit.Paint.Solid:
                            view.backgroundColor = UIColor(figmaColor: solid.color)
                        default:
                            fatalError("Unhandled")
                        }
                    }
                } else if let textNode = node as? FigmaKit.Node.Text {
                    let label = UILabel()
                    label.font = UIFont(name: textNode.style.fontFamily, size: textNode.style.fontSize)
                    for fill in vector.fills {
                        switch fill {
                        case let solid as FigmaKit.Paint.Solid:
                            label.textColor = UIColor(figmaColor: solid.color)
                        default:
                            fatalError("Unhandled")
                        }
                    }
                    label.text = textNode.characters
                    view = label
                } else {
                    fatalError("Unhandled type")
                }
                view.bounds = CGRect(origin: .zero, size: CGSize(figmaSize: vector.size))
                view.transform = CGAffineTransform(figmaTransform: vector.relativeTransform, size: vector.size).translatedBy(x: canvasMargins, y: canvasMargins)
                canvas.addSubview(view)
            default:
                fatalError("Unhandled")
            }
        }
        guard var boundingRect = boundingRect else {
            return
        }
        self.boundingRect = boundingRect
        boundingRect = boundingRect.insetBy(dx: -canvasMargins, dy: -canvasMargins)
        canvas.frame = CGRect(
            origin: CGPoint(x: -canvasMargins, y: -canvasMargins),
            size: boundingRect.size
        )
        container.contentInset = UIEdgeInsets(
            top: -boundingRect.minY,
            left: -boundingRect.minX,
            bottom: 0, right: 0
        )
        container.contentSize = boundingRect.size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        container.contentOffset = CGPoint(
            x: boundingRect.midX - container.bounds.width / 2,
            y: boundingRect.midY - container.bounds.height / 2
        )
    }
}

// foofjfjfjfjfjfjffjfjfjfjfjfjfjfjfjfjfjfjfjfjfjfjfjfjfjfjfjfj
