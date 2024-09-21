//
//  DetailView.swift
//  GitBoost
//
//  Created by 강치우 on 9/19/24.
//

import SwiftUI

struct DetailView: View {
    var todayCommits: Int = 0
    var thisWeekCommits: Int = 0
    var consecutiveCommits: Int = 0
    
    var body: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                    Text("\(todayCommits)")
                        .fontWeight(.semibold)
                    Text("오늘")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.systemGray))
                }
                
                Divider()
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                
                VStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color(.systemBlue))
                        .font(.title2)
                    Text("\(thisWeekCommits)")
                        .fontWeight(.semibold)
                    Text("이번주")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.systemGray))
                }
                
                Divider()
                    .padding(.horizontal, 40)
                    .frame(height: 50)
                
                VStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color(.systemRed))
                        .font(.title2)
                    Text("\(consecutiveCommits)")
                        .fontWeight(.semibold)
                    Text("연속")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.systemGray))
                }
                
                Spacer()
            }
        }
        
        Divider()
            .padding(.horizontal, 10)
        
        GrassView()
    }
}

#Preview {
    ContentView()
}
