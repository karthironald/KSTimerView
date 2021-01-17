//
//  LocalNotificationHelper.swift
//  KSTimerView
//
//  Created by Karthick Selvaraj on 13/12/20.
//

import Foundation
import UserNotifications

private let kLocalTimerNotificationIdentifier = "kLocalTimerNotificationIdentifier"

class LocalNotificationHelper: NSObject {
    
    static let shared = LocalNotificationHelper()
    var isEnabled = true // Set this to false if you don't want local notification to be triggered when timer completed.
    
    // MARK: - Private init method
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Custom methods
    
    private func registerForPushNotification(interval: TimeInterval) {
        let userNotification = UNUserNotificationCenter.current()
        userNotification.requestAuthorization(options: [.sound, .badge, .alert]) { (status, error) in
            if status && error == nil {
                self.scheduleNotification(with: interval)
            }
        }
    }
    
    /**Resets scheduled local notification*/
    func resetTimerNotification() {
        invalidateLocalNotification(with: [kLocalTimerNotificationIdentifier])
    }
    
    /**Adds local notification at specified interval*/
    func addLocalNoification(interval: TimeInterval) {
        if interval > 0 && isEnabled {
            let userNotification = UNUserNotificationCenter.current()
            userNotification.getNotificationSettings { (setting) in
                if setting.authorizationStatus == .authorized {
                    self.scheduleNotification(with: interval)
                } else {
                    self.registerForPushNotification(interval: interval)
                }
            }
        }
    }
    
    private func scheduleNotification(with interval: TimeInterval) {
        invalidateLocalNotification(with: [kLocalTimerNotificationIdentifier])
        
        let centre = UNUserNotificationCenter.current()
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Timer completed!"
        
        notificationContent.sound = UNNotificationSound.default
        
        let triggerAt = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: kLocalTimerNotificationIdentifier, content: notificationContent, trigger: triggerAt)
        centre.add(request) { (error) in
            if error != nil {
                print(error ?? "")
            }
        }
    }
    
    /**Invalidate local notification which we configured in `configureLocalNotification()`*/
    private func invalidateLocalNotification(with identifiers: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
}

extension LocalNotificationHelper: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .badge, .banner, .list])
    }
    
}
