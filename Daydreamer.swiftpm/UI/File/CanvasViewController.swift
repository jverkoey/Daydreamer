import UIKit
import FigmaKit

final class CanvasViewController: UIViewController {
    var file: FigmaKit.File?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "Canvas"
        label.textColor = .label
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
    }
    
    @objc func showSettings() {
        print("Settings")
    }
}
