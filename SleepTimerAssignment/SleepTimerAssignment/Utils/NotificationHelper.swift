//
//  NotificationHelper.swift
//  SleepTimerAssignment
//
//  Created by Mykola Aleshchenko on 18.05.2020.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import Foundation
import UIKit

struct NotificationHelper {
    func scheduleNotification(after: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let notificationCenter = appDelegate.notificationCenter
        
        let content = UNMutableNotificationContent()
        let identifier = "SleepTimerNotification"
        
        content.title = "Alert went off"
        content.categoryIdentifier = identifier
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(after), repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.add(request) { _ in }
        
        let okAction = UNNotificationAction(identifier: "Ok", title: "Ok", options: [])
        let category = UNNotificationCategory(identifier: identifier,
                                              actions: [okAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
}
