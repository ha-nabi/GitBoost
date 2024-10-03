//
//  ContentView.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var mainViewModel = MainViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let size = $0.size
            
            Home(mainViewModel: mainViewModel, safeArea: safeArea, size: size)
                .ignoresSafeArea(.container, edges: .top)
        }
        .onAppear {
            if LoginManager.shared.isLoggedIn {
                Task {
                    await mainViewModel.fetchGitHubData()
                }
            } else {
                mainViewModel.loadDummyData()
            }
        }
        .onChange(of: mainViewModel.isDummyLoggedOut) { _, loggedOut in
            if loggedOut {
                dismiss()
            }
        }
        .onChange(of: mainViewModel.isDummyDeleted) { _, deleted in
            if deleted {
                dismiss()
            }
        }
    }
}
