//
//  AppDelegate.swift
//  GitBoost
//
//  Created by 강치우 on 10/3/24.
//

import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 알림 권한 요청
        NotificationManager.shared.requestAuthorization()
        
        // 6시 알림 스케줄링
        NotificationManager.shared.scheduleCommitReminderNotification()
        // MARK: 테스트용도
//        NotificationManager.shared.scheduleCommitReminderNotification(atHour: 5, minute: 10, second: 30)
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    // 앱이 백그라운드에서 다시 활성화될 때 커밋 상태 체크
    func applicationDidBecomeActive(_ application: UIApplication) {
        Task {
            let isLoggedIn = LoginManager.shared.isLoggedIn
            let mainViewModel = MainViewModel(isLoggedIn: isLoggedIn)

            await mainViewModel.checkTodaysCommits()

            if !mainViewModel.hasCommittedToday {
                // 커밋이 없으면 알림을 스케줄링
                NotificationManager.shared.scheduleCommitReminderNotification()
                // MARK: 테스트 용도
//                NotificationManager.shared.scheduleCommitReminderNotification(atHour: 5, minute: 10, second: 30)
            } else {
                // 커밋이 있으면 알림을 취소
                NotificationManager.shared.removeScheduledNotifications()
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
