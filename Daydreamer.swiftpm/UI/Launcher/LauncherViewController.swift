import UIKit

protocol LauncherViewControllerDelegate: AnyObject {
    func launcher(_ launcher: LauncherViewController, open figmaID: String)
}

final class LauncherViewController: UIViewController {
    var figmaID: String? = nil {
        didSet {
            if isViewLoaded {
                urlField.text = figmaID
            }
        }
    }
    
    weak var delegate: LauncherViewControllerDelegate?
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var urlFieldWell: UIView!
    private var urlField: UITextField!
    private var openButton: UIButton!
    private let errorLabel = UILabel()
    
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
        
        let wellFrame = CGRect(origin: .zero, size: CGSize(width: 100, height: 64))
        urlFieldWell = UIView(frame: wellFrame)
        urlFieldWell.translatesAutoresizingMaskIntoConstraints = false
        urlFieldWell.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        urlFieldWell.backgroundColor = .secondarySystemFill
        urlFieldWell.layer.borderWidth = 1
        urlFieldWell.layer.cornerRadius = 32
        urlFieldWell.clipsToBounds = true
        
        urlField = UITextField(frame: wellFrame.insetBy(dx: 32, dy: 0))
        urlField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        urlField.placeholder = "Figma file url or file id"
        urlField.text = figmaID
        urlField.textAlignment = .left
        urlField.borderStyle = .none
        urlField.font = UIFont(name: "Avenir Next Medium", size: 24)!
        urlField.adjustsFontSizeToFitWidth = true
        urlField.textColor = .label
        urlFieldWell.addSubview(urlField)
        view.addSubview(urlFieldWell)
        
        openButton = UIButton(configuration: .filled(), primaryAction: UIAction(title: "Open", handler: { [weak self] action in
            self?.tryToOpen()
        }))
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.isPointerInteractionEnabled = true
        view.addSubview(openButton)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        errorLabel.textColor = .label
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.font = .preferredFont(forTextStyle: .body)
        errorLabel.alpha = 0
        errorLabel.isHidden = true
        
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            
            urlFieldWell.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Vertical positioning of the input fields.
            urlFieldWell.centerYAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor),
            openButton.topAnchor.constraint(equalToSystemSpacingBelow: urlFieldWell.bottomAnchor, multiplier: 1),
            
            // Position the error label just above the input fields.
            urlFieldWell.topAnchor.constraint(equalToSystemSpacingBelow: errorLabel.bottomAnchor, multiplier: 4),
            errorLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.centerYAnchor),
            
            // Shift the input elements up when the keyboard appears.
            openButton.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -32),
            
            urlFieldWell.leadingAnchor.constraint(equalToSystemSpacingAfter: layoutGuide.leadingAnchor, multiplier: 4),
            layoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: urlFieldWell.trailingAnchor, multiplier: 4),
            urlFieldWell.heightAnchor.constraint(equalToConstant: wellFrame.height),
            
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

extension LauncherViewController {
    private func shakeUrlField(withMessage message: String) {
        let animation = CASpringAnimation(keyPath: "position.x")
        animation.fromValue = 1
        animation.toValue = 0
        animation.initialVelocity = 100
        animation.mass = 10
        animation.stiffness = 2000
        animation.damping = 50
        animation.duration = animation.settlingDuration
        animation.isAdditive = true
        urlFieldWell.layer.add(animation, forKey: nil)
        
        errorLabel.isHidden = false
        errorLabel.text = message + "\n\n" + errorExampleMessage
        UIView.animate(withDuration: 0.2) { 
            self.errorLabel.alpha = 1
        }
    }
    
    @objc func tryToOpen() {
        guard let text = urlField.text, !text.isEmpty else {
            shakeUrlField(withMessage: "⚠️ Please provide a file URL or file id. ⚠️")
            return
        }
        let figmaId: String
        if text.isAlphanumeric() {
            figmaId = text
        } else {
            // Likely a Figma URL, let's pull out the ID.
            let matches = text.matchGroups(for: "figma.com/file/([a-zA-Z0-9]+)")
            guard matches.count == 2 else {
                shakeUrlField(withMessage: "⚠️ Unrecognized Figma URL. ⚠️")
                return
            }
            figmaId = matches[1]
        }
        
        // Success. Let's open the file!
        errorLabel.text = ""
        errorLabel.alpha = 0
        errorLabel.isHidden = true
        
        delegate?.launcher(self, open: figmaId)
    }
}

private let errorExampleMessage = """
You can get a file URL by opening a Figma file and clicking Share > Copy link.
Example URL:
https://www.figma.com/file/lUfHc6IcPjXVgVVVWjDgpx/Untitled?node-id=0%3A1
"""

extension String {
    func isAlphanumeric() -> Bool {
        return rangeOfCharacter(from: .alphanumerics.inverted) == nil
    }
    
    func matchGroups(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(
                in: self,
                range: NSRange(self.startIndex..., in: self)
            )
            return results.map {
                var matches: [String] = []
                for rangeIndex in 0..<$0.numberOfRanges {
                    let matchRange = $0.range(at: rangeIndex)
                    if let substringRange = Range(matchRange, in: self) {
                        matches.append(String(self[substringRange]))
                    }
                }
                return matches
            }.reduce([], +)
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
