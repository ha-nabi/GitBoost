//
//  IntroView.swift
//  GitBoost
//
//  Created by 강치우 on 9/22/24.
//

import SwiftUI

struct IntroView: View {
    @ObservedObject var loginManager = LoginManager.shared
    
    @State private var activePage: Page = .page1
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                if LoginManager.shared.isLoggedIn {
                    ContentView()
                } else {
                    VStack {
                        GeometryReader { geometry in
                            let size = geometry.size
                            
                            VStack {
                                Spacer(minLength: 0)
                                
                                MorphingSymbolView(
                                    symbol: activePage.rawValue,
                                    config: .init(
                                        font: .system(size: 150, weight: .bold),
                                        frame: .init(width: 250, height: 200),
                                        radius: 30,
                                        foregroundColor: .white,
                                        keyFrameDuration: 0.4,
                                        symbolAnimation: .smooth(duration: 0.5, extraBounce: 0)
                                    )
                                )
                                
                                TextContents(size: size, activePage: $activePage)
                                
                                Spacer(minLength: 0)
                                
                                IndicatorView(activePage: $activePage)
                                
                                ContinueButton(loginManager: loginManager, activePage: $activePage)
                                    .padding(.bottom)
                            }
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .top) {
                                HeaderView(activePage: $activePage, showAlert: $showAlert)
                            }
                        }
                        .background {
                            Rectangle()
                                .fill(.black.gradient)
                                .ignoresSafeArea()
                        }
                    }
                }
            }
        }
        .tint(.white)
    }
}
