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
        
        let wellFrame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        let urlFieldWell = UIView(frame: wellFrame)
        urlFieldWell.translatesAutoresizingMaskIntoConstraints = false
        urlFieldWell.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        urlFieldWell.backgroundColor = .secondarySystemFill
        urlFieldWell.layer.borderWidth = 1
        urlFieldWell.layer.cornerRadius = 32
        urlFieldWell.clipsToBounds = true
        
        let urlField = UITextField(frame: wellFrame.insetBy(dx: 32, dy: 32))
        urlField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        urlField.placeholder = "Paste a Figma file url or file id"
        urlField.textAlignment = .left
        urlField.borderStyle = .none
        urlField.font = UIFont(name: "Avenir Next Medium", size: 24)!
        urlField.adjustsFontSizeToFitWidth = true
        urlField.textColor = .label
        urlFieldWell.addSubview(urlField)
        view.addSubview(urlFieldWell)
        
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            urlFieldWell.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            urlFieldWell.centerYAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor),
            urlFieldWell.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -32),
            urlFieldWell.leadingAnchor.constraint(equalToSystemSpacingAfter: layoutGuide.leadingAnchor, multiplier: 4),
            layoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: urlFieldWell.trailingAnchor, multiplier: 4),
            urlFieldWell.heightAnchor.constraint(equalToConstant: 100),
            
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
