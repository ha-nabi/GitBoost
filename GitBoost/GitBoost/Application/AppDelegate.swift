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
    
        checkAndScheduleNotifications()  // 앱 시작 시 커밋 상태 확인
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    // 앱이 백그라운드에서 다시 활성화될 때 커밋 상태 체크
    func applicationDidBecomeActive(_ application: UIApplication) {
        checkAndScheduleNotifications()
    }

    func checkAndScheduleNotifications() {
        Task {
            let isLoggedIn = LoginManager.shared.isLoggedIn
            print("로그인 상태: \(isLoggedIn)")
            let mainViewModel = MainViewModel(isLoggedIn: isLoggedIn)
            
            print("커밋 상태 확인")
            
            await mainViewModel.checkTodaysCommits()

            // 커밋 상태에 따라 알림 예약
            if !mainViewModel.hasCommittedToday {
                print("커밋을 하지 않은 상태. 커밋 하지 않았을 때 알림 트리거 발생")
                NotificationManager.shared.scheduleCommitReminderNotification()  // 커밋 안 했을 때 알림 예약
            } else {
                print("커밋을 한 상태. 커밋을 했을 때의 알림 트리거 발생")
                NotificationManager.shared.removeScheduledNotifications()  // 기존 알림 취소
                NotificationManager.shared.scheduleCommitCompletionNotification()  // 커밋 완료 알림 예약
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
