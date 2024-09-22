//
//  CircularProgressView.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var lineWidth: CGFloat = 10
    var circleSize: CGFloat = 70
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(Color.gray)
                .frame(width: circleSize, height: circleSize)
            
            // 진행률 원 (progress만큼 채워지는 원)
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: -90)) // 시작점이 위로 오게
                .frame(width: circleSize, height: circleSize)
            
            // 진행률 텍스트
            Text(String(format: "%.0f%%", min(progress, 1.0) * 100.0))
                .font(.body)
                .bold()
        }
    }
}
