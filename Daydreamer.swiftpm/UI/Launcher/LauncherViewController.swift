import UIKit

final class LauncherViewController: UIViewController {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Avenir Next Heavy", size: 200)!
        titleLabel.text = "Daydreamer"
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont(name: "Avenir Next Medium", size: 80)!
        subtitleLabel.text = "A native Figma client for iPad, created on an iPad"
        subtitleLabel.textColor = .label
        subtitleLabel.textAlignment = .center
        subtitleLabel.lineBreakMode = .byWordWrapping
        view.addSubview(subtitleLabel)
        
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: layoutGuide.leadingAnchor, multiplier: 4),
            layoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 4),
            subtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: layoutGuide.leadingAnchor, multiplier: 4),
            layoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: subtitleLabel.trailingAnchor, multiplier: 4),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            layoutGuide.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: subtitleLabel.bottomAnchor, multiplier: 2),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateFonts(withSize: view.bounds.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { ctx in
            self.updateFonts(withSize: size)
        } completion: { _ in }
        
        print("\(size)")
    }
    
    func updateFonts(withSize size: CGSize) {
        let titleFontSize: CGFloat = (200 - 48) / (1366 - 375) * (size.width - 375) + 48
        let subtitleFontSize: CGFloat = (42 - 20) / (1366 - 375) * (size.width - 375) + 20
        titleLabel.font = titleLabel.font.withSize(titleFontSize)
        subtitleLabel.font = subtitleLabel.font.withSize(subtitleFontSize)
        if subtitleFontSize <= 20 {
            subtitleLabel.numberOfLines = 0
        } else {
            subtitleLabel.numberOfLines = 1
        }
        print(size)
    }
}

// fjfjfjfjfjfjrfjffjfjfjfjfjffjffjffjfjfj
