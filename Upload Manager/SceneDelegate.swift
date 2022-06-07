//
//  SceneDelegate.swift
//  Upload Manager
//
//  Created by Bd Stock Air-M on 11/4/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let vc = UINavigationController(rootViewController: ViewController())
        window.rootViewController = vc
        self.window = window
        window.makeKeyAndVisible()
    }
}

