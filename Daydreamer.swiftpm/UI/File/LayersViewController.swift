import FigmaKit
import SwiftUI
import UIKit

private struct Node {
    let id: String
    let title: String
    var children: [Node]? = nil
}

private struct LayersView: View {
    let file: FigmaKit.File
    let layers: [Node]
    init(file: FigmaKit.File) {
        self.file = file
        var layers: [Node] = []
        // TODO: We always show the first page right now. Allow selection of which page to view.
        for layer in file.document.children[0].children {
            layers.append(nodeFromFigmaNode(layer))
        }
        self.layers = layers
    }
    var body: some View {
        List(layers, id: \.id, children: \.children) { node in
            Text(node.title).font(.subheadline)
        }.listStyle(SidebarListStyle())
    }
}

private func nodeFromFigmaNode(_ layer: FigmaKit.Node) -> Node {
    let children = layer.children.isEmpty ? nil : layer.children.map(nodeFromFigmaNode)
    return Node(id: layer.id, title: layer.name, children: children)
}

final class LayersViewController: UIViewController {
    var file: FigmaKit.File? {
        didSet {
            renderFile()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    }
    
    private var hostingController: UIHostingController<LayersView>?
    private func renderFile() {
        guard let file = file else {
            return
        }
        if let hostingController = hostingController {
            hostingController.willMove(toParent: nil)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
            self.hostingController = nil
        }
        let hostingController = UIHostingController(rootView: LayersView(file: file))
        addChild(hostingController)
        hostingController.rootView = LayersView(file: file)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }
}
    
// fjfj
