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
                fileController.show(from: window!.rootViewController!, animated: false)
            }
        }
    }
}

extension MainSceneDelegate: LauncherViewControllerDelegate {
    func launcher(_ launcher: LauncherViewController, open figmaID: String) {
        UserDefaults.standard.set(figmaID, forKey: UserDefaultKey.figmaFileID.rawValue)
        let fileController = FileController(figmaID: figmaID)
        self.fileController = fileController
        fileController.show(from: window!.rootViewController!, animated: true)
    }
}

// fofffffffffffffffjfffffjffffjfjfffffffjffjfjfjff
