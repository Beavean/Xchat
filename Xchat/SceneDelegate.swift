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
        resetBadge()
        autoLogin()
        guard scene as? UIWindowScene != nil else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        resetBadge()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        LocationManager.shared.startUpdating()
        resetBadge()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        LocationManager.shared.stopUpdating()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        resetBadge()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        resetBadge()
    }

    // MARK: - Autologin

    private func autoLogin() {
        authListener = Auth.auth().addStateDidChangeListener({ [weak self] _, user in
            guard let authListener = self?.authListener else { return }
            Auth.auth().removeStateDidChangeListener(authListener)
            if user != nil && Constants.userDefaults.object(forKey: Constants.currentUser) != nil {
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

    private func resetBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
