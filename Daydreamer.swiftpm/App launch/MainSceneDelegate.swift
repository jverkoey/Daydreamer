import UIKit
import SwiftUI

class MainSceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?
    var fileController: FileController?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            
            let launcher = LauncherViewController()
            launcher.figmaID = UserDefaults.standard.string(forKey: UserDefaultKey.figmaFileID.rawValue)
            launcher.delegate = self
            window?.rootViewController = launcher
            
            window?.makeKeyAndVisible()
            
            if let figmaID = launcher.figmaID, !figmaID.isEmpty {
                let fileController = FileController(figmaID: figmaID)
                self.fileController = fileController
                
                showFile(animated: false)
            }
        }
    }
}

// MARK: - User actions
extension MainSceneDelegate {
    @objc private func closeFile() {
        window?.rootViewController?.dismiss(animated: true)
        fileController = nil
    }
}

extension MainSceneDelegate: LauncherViewControllerDelegate {
    func showFile(animated: Bool) {
        guard let fileController = fileController else {
            return
        }
        let closeButtonImage = UIImage(systemName: "xmark")
        fileController.closeItem = UIBarButtonItem(
            image: closeButtonImage,
            style: .plain,
            target: self,
            action: #selector(closeFile)
        )
        
        fileController.viewController.modalPresentationStyle = .fullScreen
        window!.rootViewController!.present(fileController.viewController, animated: animated)
    }
    
    func launcher(_ launcher: LauncherViewController, open figmaID: String) {
        UserDefaults.standard.set(figmaID, forKey: UserDefaultKey.figmaFileID.rawValue)
        let fileController = FileController(figmaID: figmaID)
        self.fileController = fileController
        
        showFile(animated: true)
    }
}

// fjfjfjfjfjfj
