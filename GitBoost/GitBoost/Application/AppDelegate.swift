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
            
            // 로그인된 경우에만 커밋 상태 확인 및 알림 예약
            if isLoggedIn {
                let mainViewModel = MainViewModel()
                
                print("커밋 상태 확인")
                await mainViewModel.checkTodaysCommits()

                // 알림 활성화 상태 확인
                if mainViewModel.isNotificationsEnabled {
                    // 커밋을 하지 않은 경우에만 알림을 예약합니다.
                    if !mainViewModel.hasCommittedToday {
                        print("커밋을 하지 않은 상태. 20시에 알림 트리거 발생")
                        NotificationManager.shared.scheduleCommitReminderNotification(atHour: 20)  // 20시에 알림 예약
                    } else {
                        print("커밋을 한 상태. 알림 발송하지 않음")
                        NotificationManager.shared.removeScheduledNotifications()  // 기존 알림 취소
                    }
                } else {
                    print("알림이 비활성화된 상태. 알림 예약하지 않음")
                }
            } else {
                print("로그인되지 않은 상태. 알림 예약하지 않음")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
