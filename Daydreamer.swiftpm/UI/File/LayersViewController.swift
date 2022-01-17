import SwiftUI
import UIKit

struct RootView: View {
    var body: some View {
        VStack {
            Text("Hello")
            Text("Hello")
        }
    }
} 

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

final class LayersViewController: UIViewController {
    private let hostingController: UIHostingController<RootView>
    init() {
        hostingController = UIHostingController(rootView: RootView())
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(hostingController)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
    
// fjfj
