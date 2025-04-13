import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var isEditing = false
    
    init() {
        // Initialize with default values first
        self.userProfile = UserProfile()
        
        // Then load or create profile
        self.loadOrCreateProfile()
        
        // Listen for trade history updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tradeHistoryUpdated),
            name: NSNotification.Name("TradeHistoryUpdated"),
            object: nil
        )
    }
    
    @objc private func tradeHistoryUpdated() {
        // Load trade history and update total trades
        if let historyData = UserDefaults.standard.data(forKey: "tradeHistory"),
           let history = try? JSONDecoder().decode([TradeHistory].self, from: historyData) {
            userProfile.totalTrades = history.count
            saveProfile()
        }
    }
    
    private func loadOrCreateProfile() {
        if let profileData = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: profileData) {
            self.userProfile = profile
        } else {
            let publicKey = generatePublicKey()
            self.userProfile = UserProfile(alias: "Scavenger", publicKey: publicKey, tagline: "Trust no one. Trade often.")
        }
        
        // Load initial trade count
        if let historyData = UserDefaults.standard.data(forKey: "tradeHistory"),
           let history = try? JSONDecoder().decode([TradeHistory].self, from: historyData) {
            userProfile.totalTrades = history.count
        }
    }
    
    private func generatePublicKey() -> String {
        // This is a placeholder - in a real app, you'd use proper cryptography
        return UUID().uuidString
    }
    
    func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
    
    func updateTradeCount() {
        userProfile.totalTrades += 1
        saveProfile()
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    // Theme colors
    private let lightGray = Color(red: 0.2, green: 0.2, blue: 0.2)
    private let eerieGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(eerieGreen)
                    
                    Text(viewModel.userProfile.alias)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(viewModel.userProfile.tagline)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Public Key
                VStack(alignment: .leading, spacing: 8) {
                    Text("Public Key")
                        .font(.headline)
                        .foregroundColor(eerieGreen)
                    
                    Text(viewModel.userProfile.publicKey)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                    // Trade Stats
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trade Statistics")
                            .font(.headline)
                            .foregroundColor(eerieGreen)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total Trades")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(viewModel.userProfile.totalTrades)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                //            .background(lightGray.ignoresSafeArea())
                .navigationTitle("Profile")
                .navigationBarItems(trailing: Button(action: { viewModel.isEditing = true }) {
                    Image(systemName: "pencil")
                })
                .sheet(isPresented: $viewModel.isEditing) {
                    EditProfileView(viewModel: viewModel)
                }
            }
        }
    }
    
    struct EditProfileView: View {
        @ObservedObject var viewModel: ProfileViewModel
        @Environment(\.dismiss) var dismiss
        @State private var alias: String
        @State private var tagline: String
        
        init(viewModel: ProfileViewModel) {
            self.viewModel = viewModel
            _alias = State(initialValue: viewModel.userProfile.alias)
            _tagline = State(initialValue: viewModel.userProfile.tagline)
        }
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Profile Information")) {
                        TextField("Alias", text: $alias)
                        TextField("Tagline", text: $tagline)
                    }
                }
                .navigationTitle("Edit Profile")
                .navigationBarItems(
                    leading: Button("Cancel") { dismiss() },
                    trailing: Button("Save") {
                        viewModel.userProfile.alias = alias
                        viewModel.userProfile.tagline = tagline
                        viewModel.saveProfile()
                        dismiss()
                    }
                )
            }
        }
    }

#Preview {
    ProfileView()
}
