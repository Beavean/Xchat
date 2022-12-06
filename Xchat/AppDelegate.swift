//
//  AppDelegate.swift
//  Xchat
//
//  Created by Beavean on 04.11.2022.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var firstRun: Bool?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        firstRunCheck()
        LocationManager.shared.startUpdating()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    //MARK: - First Run
    
    private func firstRunCheck() {
        firstRun = userDefaults.bool(forKey: kFIRSTRUN)
        guard let firstRun else { return }
        if !firstRun {
            let status = Status.allCases.map { $0.rawValue }
            userDefaults.set(status, forKey: kSTATUS)
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.synchronize()
        }
    }
}
