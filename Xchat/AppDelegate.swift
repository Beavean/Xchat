//
//  AppDelegate.swift
//  Xchat
//
//  Created by Beavean on 04.11.2022.
//

import UIKit
import FirebaseMessaging
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var firstRun: Bool?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        requestPushNotificationPermission()
        firstRunCheck()
        application.registerForRemoteNotifications()
        LocationManager.shared.startUpdating()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    //MARK: - Remote notifications
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("unable to register for remote notifications ", error.localizedDescription)
    }

    private func requestPushNotificationPermission() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in
        }
    }
    
    private func updateUserPushId(newPushId: String) {
        if var user = User.currentUser {
            user.pushId = newPushId
            saveUserLocally(user)
            FirebaseUserListener.shared.updateUserInFirebase(user)
        }
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        print("DEBUG: user push token is ", fcmToken)
        updateUserPushId(newPushId: fcmToken)
    }
}

