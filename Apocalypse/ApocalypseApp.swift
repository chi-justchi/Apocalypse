//
//  ApocalypseApp.swift
//  Apocalypse
//
//  Created by Chi Vo on 4/13/25.
//

import SwiftUI

@main
struct ApocalypseApp: App {
    @StateObject private var authModel = AuthenticationModel()
    
    var body: some Scene {
        WindowGroup {
            if authModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView(authModel: authModel)
            }
        }
    }
}
