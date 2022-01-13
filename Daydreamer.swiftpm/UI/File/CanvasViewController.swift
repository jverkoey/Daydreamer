import UIKit
import FigmaKit

final class CanvasViewController: UIViewController {
    var file: FigmaKit.File? {
        didSet {
            renderFile()
        }
    }
    var imageFills: [String: String]? {
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
    private var boundingRect: CGRect?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        container.frame = view.bounds
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.delegate = self
        container.minimumZoomScale = 0.01
        container.maximumZoomScale = 10.0
        view.addSubview(container)
        
        let hover = UIPanGestureRecognizer(target: self, action: #selector(hovering(_:)))
        view.addGestureRecognizer(hover)
    }
    
    @objc func showSettings() {
        print("Settings")
    }
    
    enum TrackpadDragGestureState {
        case listening
        case spacePressed
        case dragging
    }
    var trackpadDragGestureState: TrackpadDragGestureState = .listening
}

extension CanvasViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
}

private let canvasMargins: CGFloat = 1000

extension CanvasViewController {
    
    func viewForNode(_ node: FigmaKit.Node) -> UIView {
        let view: UIView
        switch node {
        case let vector as FigmaKit.Node.Vector:
            let frame = CGRect(figmaRect: vector.absoluteBoundingBox)
            if let existingRect = boundingRect {
                boundingRect = existingRect.union(frame)
            } else {
                boundingRect = frame
            }
            
            if let textNode = node as? FigmaKit.Node.Text {
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
                view = UIView()
                if let frameNode = node as? FigmaKit.Node.Frame {
                    view.clipsToBounds = frameNode.clipsContent
                }
                for fill in vector.fills {
                    switch fill {
                    case let solid as FigmaKit.Paint.Solid:
                        view.backgroundColor = UIColor(figmaColor: solid.color)
                    case let image as FigmaKit.Paint.Image:
                        guard let imageFills = imageFills,
                              let imageRef = image.ref,
                              let imageUrlPath = imageFills[imageRef],
                              let imageUrl = URL(string: imageUrlPath) else {
                            view.backgroundColor = .yellow
                            break
                        }
                        let imageView = UIImageView(frame: view.bounds)
                        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        view.addSubview(imageView)
                        DispatchQueue.global().async {
                            guard let data = try? Data(contentsOf: imageUrl),
                                  let image = UIImage(data: data) else {
                                      return
                                  }
                            DispatchQueue.main.async {
                                imageView.image = image
                            }
                        }
                    default:
                        print("Unhandled fill: \(fill)")
                    }
                }
            }
            view.bounds = CGRect(origin: .zero, size: CGSize(figmaSize: vector.size))
            view.transform = CGAffineTransform(figmaTransform: vector.relativeTransform, size: vector.size)
        default:
            fatalError("Unhandled")
        }
        for child in node.children {
            let subview = viewForNode(child)
            view.addSubview(subview)
        }
        return view
    }
    
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
        boundingRect = nil
        canvas.removeFromSuperview()
        canvas = UIView()
        container.addSubview(canvas)
        
        canvas.backgroundColor = container.backgroundColor
        
        for node in page.children {
            let view = viewForNode(node)
            view.transform = view.transform.translatedBy(x: canvasMargins, y: canvasMargins)
            canvas.addSubview(view)
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
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        
        for press in presses {
            if press.key?.keyCode == .keyboardSpacebar {
                trackpadDragGestureState = .spacePressed
            }
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        
        for press in presses {
            if press.key?.keyCode == .keyboardSpacebar {
                trackpadDragGestureState = .listening
            }
        }
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesCancelled(presses, with: event)
        
        for press in presses {
            if press.key?.keyCode == .keyboardSpacebar {
                trackpadDragGestureState = .listening
            }
        }
    }
    
    @objc
    func hovering(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if trackpadDragGestureState == .spacePressed {
                trackpadDragGestureState = .dragging
            }
        case .changed:
            guard trackpadDragGestureState == .dragging else {
                break
            }
            let translation = recognizer.translation(in: recognizer.view)
            var offset = container.contentOffset
            offset.x -= translation.x
            offset.y -= translation.y
            container.contentOffset = offset
            recognizer.setTranslation(.zero, in: recognizer.view)
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let boundingRect = boundingRect {
            container.contentOffset = CGPoint(
                x: boundingRect.midX - container.bounds.width / 2,
                y: boundingRect.midY - container.bounds.height / 2
            )
        }
    }
}

// fjfjfjfjfjfjfjfjfjfjfjffjfjfjfjfjfjfjfjfjfjfjfjfjfjfjfjfj
