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
        LoginManager.shared.fetchContributionsData { result in
            switch result {
            case .success(let contributionsData):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"

                // 1년 전 날짜 계산
                let today = Date()
                guard let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today) else {
                    return
                }

                // 1년 전 이후 기여 필터링
                let allContributions = contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks
                    .flatMap { $0.contributionDays }
                    .compactMap { contributionDay -> Contribution? in
                        guard let date = dateFormatter.date(from: contributionDay.date), date >= oneYearAgo else {
                            return nil
                        }
                        return Contribution(date: date, count: contributionDay.contributionCount)
                    }

                // 최근 1년 동안의 총 기여 계산
                let totalContributions = allContributions.reduce(0) { $0 + $1.count }
                DispatchQueue.main.async {
                    self.totalContributionsLastYear = totalContributions
                }

                // 최근 5개월 데이터 필터링
                guard let fiveMonthsAgo = Calendar.current.date(byAdding: .month, value: -5, to: today) else {
                    return
                }

                let recentContributions = allContributions.filter { $0.date >= fiveMonthsAgo }

                DispatchQueue.main.async {
                    self.contributions = recentContributions
                    self.isLoading = false
                }

            case .failure(let error):
                print("Error fetching contributions data: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
