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
                if activePage == .page4 {
                    loginManager.login()
                } else {
                    activePage = activePage.nextPage
                }
            } label: {
                Text(activePage == .page4 ? "Github 연동하기" : "다음으로")
                    .contentTransition(.identity)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                    .padding(.vertical, 15)
                    .frame(maxWidth: activePage == .page4 ? 260 : 180)
                    .background(.white, in: .rect(cornerRadius: 12))
            }
            .animation(.smooth(duration: 0.5, extraBounce: 0), value: activePage)
        }
    }
}
