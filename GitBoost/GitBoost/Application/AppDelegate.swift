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
            
            if isLoggedIn {
                let mainViewModel = MainViewModel()
                
                print("GitHub 데이터를 가져오는 중...")
                await mainViewModel.fetchGitHubData()  // 기여 데이터를 먼저 가져옵니다
                
                if let contributionsData = mainViewModel.contributionsData {
                    let userTimeZone = TimeZone.current  // 사용자의 로컬 시간대
                    print("사용자 시간대: \(userTimeZone.identifier)")
                    
                    let hasCommittedToday = mainViewModel.checkTodaysCommits(from: contributionsData, in: userTimeZone)
                    
                    // 커밋 여부에 따라 로그 출력
                    if hasCommittedToday {
                        print("오늘 커밋을 했습니다.")
                    } else {
                        print("오늘 커밋을 하지 않았습니다.")
                    }
                    
                    // 알림 활성화 상태 확인
                    if mainViewModel.isNotificationsEnabled {
                        if !hasCommittedToday {
                            print("커밋을 하지 않은 상태. 20시에 알림 예약")
                            NotificationManager.shared.scheduleCommitReminderNotification(atHour: 20)
                        } else {
                            print("커밋을 한 상태. 알림 발송하지 않음")
                            NotificationManager.shared.removeScheduledNotifications()  // 기존 알림 취소
                        }
                    } else {
                        print("알림이 비활성화된 상태. 알림 예약하지 않음")
                    }
                } else {
                    print("기여 데이터를 가져오지 못했습니다.")
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
