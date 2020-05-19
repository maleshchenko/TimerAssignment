//
//  AppDelegate.swift
//  SleepTimerAssignment
//
//  Created by Mykola Aleshchenko on 16.05.2020.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import UIKit
import AVFoundation
import os.log

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        notificationCenter.delegate = self
        requestNotificationPermissionIfNeeded()
        
        AVAudioSession.sharedInstance().requestRecordPermission { result in
            if !result {
                os_log("User declined microphone permission")
            }
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

// MARK: - Notifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if UIApplication.shared.applicationState == .background {
            completionHandler([.alert])
        } else {
            completionHandler([])
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.alertNotification), object: nil)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationConstants.openAppFromNotification), object: nil)
        completionHandler()
    }
}

extension AppDelegate {
    func requestNotificationPermissionIfNeeded() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let notificationCenter = appDelegate.notificationCenter
        
        let options: UNAuthorizationOptions = [.alert]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                os_log("User has declined notifications")
            }
            
            if error != nil {
                os_log("Notifications error: %{public}@", error.debugDescription)
            }
        }
    }
}
