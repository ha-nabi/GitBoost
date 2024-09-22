//
//  HeaderView.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI

struct HeaderView: View {
    @Binding var activePage: Page
    
    var body: some View {
        HStack {
            Button {
                activePage = activePage.previousPage
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .contentShape(.rect)
            }
            .opacity(activePage != .page1 ? 1 : 0)
            
            Spacer(minLength: 0)
            
            Button("Skip") {
                activePage = .page3
            }
            .fontWeight(.semibold)
            .opacity(activePage != .page3 ? 1 : 0)
        }
        .foregroundStyle(.white)
        .animation(.snappy(duration: 0.35, extraBounce: 0), value: activePage)
        .padding(15)
    }
}
