//
//  MainViewModel.swift
//  GitBoost
//
//  Created by 강치우 on 9/22/24.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var userInfo: UserInfo?
    @Published var contributionsData: ContributionsData?
    @Published var errorMessage: String?
    
    @Published var followers: [UserInfo] = []
    @Published var following: [UserInfo] = []
    
    @Published var scrollViewOffset: CGFloat = 0
    
    @Published var showLogoutDialog = false
    @Published var showDeleteAccountDialog = false
    
    func fetchGitHubData() {
        // GitHub 프로필 데이터 가져오기
        LoginManager.shared.fetchUserInfo { result in
            switch result {
            case .success(let userInfo):
                DispatchQueue.main.async {
                    self.userInfo = userInfo
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
        // GitHub 기여도 데이터 가져오기
        LoginManager.shared.fetchContributionsData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.contributionsData = data
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    print("Failed to fetch contributions data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // 오늘 커밋 수
    func calculateTodayCommits(from contributionsData: ContributionsData) -> Int {
        let contributionDays = contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks.flatMap { $0.contributionDays }
        return contributionDays.last?.contributionCount ?? 0
    }

    // 이번 주 커밋 수
    func calculateThisWeekCommits(from contributionsData: ContributionsData) -> Int {
        let currentWeek = contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks.last
        return currentWeek?.contributionDays.reduce(0, { $0 + $1.contributionCount }) ?? 0
    }

    // 연속된 커밋 날짜
    func calculateConsecutiveCommits(from contributionsData: ContributionsData) -> Int {
        let calendar = Calendar.current
        var consecutiveCommits = 0
        var previousDate: Date?
        
        for week in contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks.reversed() {
            for day in week.contributionDays.reversed() {
                if let currentDate = dateFormatter.date(from: day.date) {
                    if previousDate == nil {
                        if day.contributionCount > 0 {
                            consecutiveCommits += 1
                            previousDate = currentDate
                        }
                    } else {
                        let difference = calendar.dateComponents([.day], from: currentDate, to: previousDate!).day
                        if difference == 1 {
                            if day.contributionCount > 0 {
                                consecutiveCommits += 1
                                previousDate = currentDate
                            } else {
                                return consecutiveCommits
                            }
                        } else {
                            return consecutiveCommits
                        }
                    }
                }
            }
        }
        
        return consecutiveCommits
    }
    
    func logout() {
        print("로그아웃")
        LoginManager.shared.logout()
    }
    
    func deleteAccount() {
        print("탈퇴하기")
        LoginManager.shared.deleteAccount()
    }

    // 날짜 포맷터
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
