//
//  ScoreBarChart.swift
//  GitBoost
//
//  Created by 강치우 on 9/22/24.
//

import SwiftUI
import Charts

struct ScoreBarChart: View {
    let data: [ChartData]
    let colors: [Color] = [.blue, .green, .orange, .purple, .red]

    @State private var animatedValues: [Double] = []

    var body: some View {
        VStack {
            Chart {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, dataPoint in
                    BarMark(
                        x: .value("Type", dataPoint.label),
                        y: .value("Score", animatedValues[safe: index] ?? 0)
                    )
                    .foregroundStyle(colors[safe: index] ?? .blue)
                }
            }
            .chartYScale(domain: 0...(maxValue() * 1.2))
            .padding()
            .onAppear {
                animatedValues = Array(repeating: 0.0, count: data.count)
                
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        for (index, dataPoint) in data.enumerated() {
                            animatedValues[index] = Double(dataPoint.value)
                        }
                    }
                }
            }
        }
    }

    // 차트의 최대 값 계산
    private func maxValue() -> Double {
        return data.map { Double($0.value) }.max() ?? 0
    }
}

// 안전하게 배열 인덱스 접근하기 위한 확장
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
