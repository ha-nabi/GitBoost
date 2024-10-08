//
//  ContinueButton.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI

struct ContinueButton: View {
    @ObservedObject var loginManager: LoginManager
    
    @Binding var activePage: Page
    
    var body: some View {
        VStack(spacing: 10) {
            Button {
                if activePage == .page3 {
                    loginManager.login()
                } else {
                    activePage = activePage.nextPage
                }
            } label: {
                Text(activePage == .page3 ? AppLocalized.githubLoginText : AppLocalized.nextText)
                    .contentTransition(.identity)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                    .padding(.vertical, 15)
                    .frame(maxWidth: activePage == .page3 ? 260 : 180)
                    .background(.white, in: .rect(cornerRadius: 12))
            }
            .animation(.smooth(duration: 0.5, extraBounce: 0), value: activePage)
        }
    }
}
