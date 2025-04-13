import SwiftUI

struct MainTabView: View {
    var body: some View {
        ZStack {
            // Background Image
//            Image("BackgroundPostApo")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//                .opacity(0.3) // Adjust opacity to make it less distracting
            
            // Content
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                TradeView()
                    .tabItem {
                        Label("Trade", systemImage: "arrow.triangle.2.circlepath")
                    }
                
                LogView()
                    .tabItem {
                        Label("Log", systemImage: "list.bullet")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
            .accentColor(Color(red: 0.2, green: 0.8, blue: 0.2)) // Eerie green accent
        }
    }
}

#Preview {
    MainTabView()
} 
