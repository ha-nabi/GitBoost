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
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleCommitReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "GitBoost"
        content.body = "오늘 커밋을 잊으신건 아닌가요?"
        content.sound = .default
        
        // 트리거를 오후 6시로 설정
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "commitReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling commit reminder notification: \(error.localizedDescription)")
            } else {
                print("Commit reminder notification scheduled for 6 PM.")
            }
        }
    }
    
    //MARK: - 이벤트 트리거 테스트
//    func scheduleCommitReminderNotification(atHour hour: Int, minute: Int, second: Int) {
//        let content = UNMutableNotificationContent()
//        content.title = "GitBoost"
//        content.body = "오늘 커밋을 잊으신건 아닌가요?"
//        content.sound = .default
//        
//        // 트리거를 특정 시, 분, 초에 설정
//        var dateComponents = DateComponents()
//        dateComponents.hour = hour
//        dateComponents.minute = minute
//        dateComponents.second = second
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//        
//        let request = UNNotificationRequest(identifier: "commitReminder", content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling commit reminder notification: \(error.localizedDescription)")
//            } else {
//                print("Commit reminder notification scheduled for \(hour):\(minute):\(second).")
//            }
//        }
//    }
    
    func removeScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["commitReminder"])
    }
}
