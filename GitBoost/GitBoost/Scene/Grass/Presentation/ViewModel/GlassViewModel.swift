//
//  GlassViewModel.swift
//  GitBoost
//
//  Created by 강치우 on 9/22/24.
//

import SwiftUI

final class GlassViewModel: ObservableObject {
    @Published var contributions: [Contribution] = []
    @Published var totalContributionsLastYear: Int = 0
    @Published var isLoading: Bool = true

    func fetchContributionsData() {
        isLoading = true

        // 로그인 여부에 따른 더미 데이터 사용
        if !LoginManager.shared.isLoggedIn {
            // 더미 데이터를 생성
            let dummyContributions = Contribution.generate()
            let totalContributions = dummyContributions.reduce(0) { $0 + $1.count }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // 가벼운 딜레이 추가
                self.contributions = dummyContributions
                self.totalContributionsLastYear = totalContributions
                self.isLoading = false
            }
        } else {
            Task {
                await fetchRealContributionsData()
            }
        }
    }

    private func fetchRealContributionsData() async {
        do {
            let contributionsData = try await LoginManager.shared.fetchContributionsData()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            let today = Date()
            guard let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today) else {
                return
            }

            let allContributions = contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks
                .flatMap { $0.contributionDays }
                .compactMap { contributionDay -> Contribution? in
                    guard let date = dateFormatter.date(from: contributionDay.date), date >= oneYearAgo else {
                        return nil
                    }
                    return Contribution(date: date, count: contributionDay.contributionCount)
                }

            let totalContributions = allContributions.reduce(0) { $0 + $1.count }
            DispatchQueue.main.async {
                self.totalContributionsLastYear = totalContributions
            }

            guard let fiveMonthsAgo = Calendar.current.date(byAdding: .month, value: -5, to: today) else {
                return
            }

            let recentContributions = allContributions.filter { $0.date >= fiveMonthsAgo }

            DispatchQueue.main.async {
                self.contributions = recentContributions
                self.isLoading = false
            }

        } catch {
            print("Error fetching contributions data: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
