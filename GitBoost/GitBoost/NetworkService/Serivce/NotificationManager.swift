//
//  NotificationManager.swift
//  GitBoost
//
//  Created by 강치우 on 10/3/24.
//

import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if success {
                print("알림 권한 확인")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    // 커밋 리마인더 알림
    func scheduleCommitReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "GitBoost"
        content.body = AppLocalized.CommitReminderNotificationText
        content.sound = .default
        
        // 10초 후에 알림 트리거
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "commitReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling commit reminder notification: \(error.localizedDescription)")
            } else {
                print("커밋 안했을 때 알림 예약")
            }
        }
    }

    // 커밋 완료 알림
    func scheduleCommitCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "GitBoost"
        content.body = AppLocalized.CommitReminderNotificationSuccessText
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)  // 5초 후 알림
        
        let request = UNNotificationRequest(identifier: "commitCompletion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling commit completion notification: \(error.localizedDescription)")
            } else {
                print("커밋을 했을 때 알림 예약")
            }
        }
    }
    
    func removeScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["commitReminder", "commitCompletion"])
    }
}
