//
//  GrassView.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI
import Charts

struct GrassView: View {
    @ObservedObject var viewModel: GlassViewModel

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isLoading {
                ProgressView("Loading contributions...")
                    .padding()
            } else {
                Text("\(viewModel.totalContributionsLastYear) ")
                    .font(.title3)
                    .fontWeight(.semibold)
                +
                Text(" contributions in the last year")
                    .font(.body)
                    .fontWeight(.medium)
                
                Chart(viewModel.contributions) { contribution in
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
            viewModel.fetchContributionsData()
        }
    }

    // MARK: - 차트 관련
    private func weekday(for date: Date) -> Int {
        let calendar = Calendar(identifier: .iso8601)
        let weekday = calendar.component(.weekday, from: date)
        return (weekday == 0) ? 7 : (weekday - 1) // 월요일이 1, 일요일이 7
    }

    private var aspectRatio: Double {
        if viewModel.contributions.isEmpty {
            return 1
        }
        let firstDate = viewModel.contributions.first!.date
        let lastDate = viewModel.contributions.last!.date
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
