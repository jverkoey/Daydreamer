import UIKit

final class LayersViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "Layers"
        label.textColor = .label
        label.sizeToFit()
        label.center = view.center
        view.addSubview(label)
    }
}
