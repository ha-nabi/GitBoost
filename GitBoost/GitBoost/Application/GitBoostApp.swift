//
//  GitBoostApp.swift
//  GitBoost
//
//  Created by 강치우 on 9/19/24.
//

import SwiftUI

@main
struct GitBoostApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            IntroView()
        }
    }
}
