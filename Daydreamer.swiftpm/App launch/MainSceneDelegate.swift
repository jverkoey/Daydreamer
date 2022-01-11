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
            window?.rootViewController = LauncherViewController()
            
            window?.makeKeyAndVisible()
        }
    }
}

// foo
