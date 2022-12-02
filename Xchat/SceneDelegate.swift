//
//  SceneDelegate.swift
//  Xchat
//
//  Created by Beavean on 04.11.2022.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        autologin()
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        LocationManager.shared.startUpdating()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        LocationManager.shared.stopUpdating()
    }
    
    //MARK: - Autologin
    
    func autologin() {
        authListener = Auth.auth().addStateDidChangeListener({ [weak self] auth, user in
            guard let authListener = self?.authListener else { return }
            Auth.auth().removeStateDidChangeListener(authListener)
            if user != nil && userDefaults.object(forKey: kCURRENTUSER) != nil {
                DispatchQueue.main.async {
                    self?.enterTheApplication()
                }
            }
        })
    }
    
    private func enterTheApplication() {
        guard let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? UITabBarController else { return }
        self.window?.rootViewController = mainView
    }
}

