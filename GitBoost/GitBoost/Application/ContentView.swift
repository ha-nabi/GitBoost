//
//  ContentView.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var mainViewModel: MainViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    init() {
        _mainViewModel = StateObject(wrappedValue: MainViewModel(isLoggedIn: UserDefaults.standard.bool(forKey: "isLoggedIn")))
    }
    
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let size = $0.size
            
            Home(safeArea: safeArea, size: size)
                .environmentObject(mainViewModel)
                .ignoresSafeArea(.container, edges: .top)
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
