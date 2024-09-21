//
//  GrassView.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI
import Charts

struct GrassView: View {
    @State var contributions: [Contribution] = []
    @State var totalContributionsLastYear: Int = 0
    @State var isLoading = true

    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                ProgressView("Loading contributions...")
                    .padding()
            } else {
                Text("\(totalContributionsLastYear) ")
                    .font(.title3)
                    .fontWeight(.semibold)
                +
                Text(" contributions in the last year")
                    .font(.body)
                    .fontWeight(.medium)
                
                Chart(contributions) { contribution in
                    RectangleMark(
                        xStart: .value("Start week", contribution.date, unit: .weekOfYear),
                        xEnd: .value("End week", contribution.date, unit: .weekOfYear),
                        yStart: .value("Start weekday", weekday(for: contribution.date)),
                        yEnd: .value("End weekday", weekday(for: contribution.date) + 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4).inset(by: 0.8))
                    .foregroundStyle(color(for: contribution.count)) // 차트 색
                    .foregroundStyle(by: .value("Count", contribution.count)) // 범례
                }
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                }
                .chartPlotStyle { content in
                    content
                        .aspectRatio(aspectRatio, contentMode: .fit)
                }
                .chartXAxis {
                    AxisMarks(position: .top, values: .stride(by: .month)) {
                        AxisValueLabel(format: .dateTime.month())
                            .foregroundStyle(Color(.label))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: [1, 3, 5]) { value in
                        if let value = value.as(Int.self) {
                            AxisValueLabel {
                                Text(shortWeekdaySymbols[value - 1])
                                    .offset(y: 10)
                            }
                            .foregroundStyle(Color(.label))
                        }
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false, reversed: true))
                .chartLegend {
                    HStack(spacing: 4) {
                        Text("Less")
                        ForEach(legendColors, id: \.self) { color in
                            color
                                .frame(width: 10, height: 10)
                                .cornerRadius(2)
                        }
                        Text("More")
                    }
                    .padding(4)
                    .foregroundStyle(Color(.label))
                    .font(.caption2)
                }
            }
        }
        .padding(.horizontal, 10)
        .onAppear {
            fetchAndApplyContributionsData()
        }
        .refreshable {
            fetchAndApplyContributionsData()
        }
    }

    // MARK: - Private
    private func fetchAndApplyContributionsData() {
        isLoading = true
        LoginManager.shared.fetchContributionsData { result in
            switch result {
            case .success(let contributionsData):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"

                // 오늘 날짜 기준으로 1년 전의 날짜 계산
                let today = Date()
                guard let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today) else {
                    return
                }

                // 받은 데이터를 Contribution으로 변환하고 1년 전 이후 데이터만 필터링
                let allContributions = contributionsData.data.viewer.contributionsCollection.contributionCalendar.weeks
                    .flatMap { $0.contributionDays }
                    .compactMap { contributionDay -> Contribution? in
                        guard let date = dateFormatter.date(from: contributionDay.date), date >= oneYearAgo else {
                            return nil
                        }
                        return Contribution(date: date, count: contributionDay.contributionCount)
                    }

                // 최근 1년 동안의 총 커밋 수 계산
                let totalContributions = allContributions.reduce(0) { $0 + $1.count }
                DispatchQueue.main.async {
                    self.totalContributionsLastYear = totalContributions // 최근 1년 동안의 총 커밋 수 저장
                }

                // 최근 5개월의 데이터 필터링
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

    private func weekday(for date: Date) -> Int {
        let calendar = Calendar(identifier: .iso8601)
        let weekday = calendar.component(.weekday, from: date)
        return (weekday == 0) ? 7 : (weekday - 1) // 월요일이 1, 일요일이 7
    }

    private var aspectRatio: Double {
        if contributions.isEmpty {
            return 1
        }
        let firstDate = contributions.first!.date
        let lastDate = contributions.last!.date
        let firstWeek = Calendar.current.component(.weekOfYear, from: firstDate)
        let lastWeek = Calendar.current.component(.weekOfYear, from: lastDate)
        return Double(lastWeek - firstWeek + 1) / 7
    }

    private func color(for count: Int) -> Color {
        if count == 0 {
            return Color(.systemGray5)
        } else {
            return Color(.systemGreen).opacity(Double(count + 1) / 10)
        }
    }

    private var legendColors: [Color] {
        Array(stride(from: 0, to: 10, by: 2).map { color(for: $0) })
    }

    private let shortWeekdaySymbols: [String] = {
        var shortWeekdaySymbols = Calendar.current.shortWeekdaySymbols
        let sunday = shortWeekdaySymbols.removeFirst()
        shortWeekdaySymbols.append(sunday)
        return shortWeekdaySymbols
    }()
}
