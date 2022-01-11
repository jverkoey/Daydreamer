import UIKit
import FigmaKit

final class CanvasViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let gearImage = UIImage(systemName: "gear")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: gearImage, style: .plain, target: self, action: #selector(showSettings))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    }
    
    @objc func showSettings() {
        print("Settings")
    }
}
