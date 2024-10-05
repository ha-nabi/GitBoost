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
    func scheduleCommitReminderNotification(atHour hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "GitBoost"
        content.body = AppLocalized.commitReminderNotificationText
        content.sound = .default
        
        // 20시 알림을 위한 시간 기반 트리거
        var dateComponents = DateComponents()
        dateComponents.hour = hour  // 20시(8PM)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "commitReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling commit reminder notification: \(error.localizedDescription)")
            } else {
                print("커밋 안했을 때 20시에 알림 예약")
            }
        }
    }

    func removeScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["commitReminder"])
    }
}
