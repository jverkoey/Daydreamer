import UIKit
import SwiftUI

class MainSceneDelegate: NSObject, UIWindowSceneDelegate {
    var window:UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            
            let vc = FigmaFileViewController()
            
            window?.rootViewController = vc
            
            window?.makeKeyAndVisible()
        }
    }
}
