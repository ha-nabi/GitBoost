//
//  GrassView.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI
import Charts

struct GrassView: View {
    @State var contributions: [Contribution] = Contribution.generate()

    var body: some View {
        VStack(alignment: .leading) {
            Text("1,474 contributions in the last year")
                .font(.title3)
                .fontWeight(.medium)
                .padding(.leading)
            
            Chart(contributions) { contribution in
                RectangleMark(
                    xStart: .value("Start week", contribution.date, unit: .weekOfYear),
                    xEnd: .value("End week", contribution.date, unit: .weekOfYear),
                    yStart: .value("Start weekday", weekday(for: contribution.date)),
                    yEnd: .value("End weekday", weekday(for: contribution.date) + 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 6).inset(by: 2))
                .foregroundStyle(by: .value("Count", contribution.count))
            }
            .padding()
            .chartPlotStyle { content in
                content
                    .aspectRatio(aspectRatio, contentMode: .fit)
            }
            .chartForegroundStyleScale(range: Gradient(colors: colors))
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

    // MARK: - Private
    private func weekday(for date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date)
        let adjustedWeekday = (weekday == 1) ? 7 : (weekday - 1)
        return adjustedWeekday
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

    private var colors: [Color] {
        (0...10).map { index in
            if index == 0 {
                return Color(.systemGray5)
            }
            return Color(.systemGreen).opacity(Double(index) / 10)
        }
    }

    private var legendColors: [Color] {
        Array(stride(from: 0, to: colors.count, by: 2).map { colors[$0] })
    }

    private let shortWeekdaySymbols: [String] = {
        var shortWeekdaySymbols = Calendar.current.shortWeekdaySymbols
        let sunday = shortWeekdaySymbols.removeFirst()
        shortWeekdaySymbols.append(sunday)
        return shortWeekdaySymbols
    }()
}

#Preview(traits: .sizeThatFitsLayout) {
    GrassView()
}
