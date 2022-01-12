import UIKit
import SwiftUI

class MainSceneDelegate: NSObject, UIWindowSceneDelegate {
    var window:UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
//            
//            let rootController = UISplitViewController(style: .tripleColumn)
//            rootController.setViewController(CanvasViewController(), for: .secondary)
//            
            let launcher = LauncherViewController()
            launcher.figmaID = UserDefaults.standard.string(forKey: UserDefaultKey.figmaFileID.rawValue)
            launcher.delegate = self
            window?.rootViewController = launcher
            
            window?.makeKeyAndVisible()
        }
    }
}

extension MainSceneDelegate: LauncherViewControllerDelegate {
    func launcher(_ launcher: LauncherViewController, open figmaID: String) {
        UserDefaults.standard.set(figmaID, forKey: UserDefaultKey.figmaFileID.rawValue)
        print(figmaID)
        // TODO: Present the file UI.
    }
}
