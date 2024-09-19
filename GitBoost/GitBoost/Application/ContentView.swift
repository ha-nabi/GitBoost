//
//  ContentView.swift
//  GitBoost
//
//  Created by 강치우 on 9/20/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            GeometryReader {
                let safeArea = $0.safeAreaInsets
                let size = $0.size
                
                Home(safeArea: safeArea, size: size)
                    .ignoresSafeArea(.container, edges: .top)
            }
        }
    }
}

#Preview {
    ContentView()
}
