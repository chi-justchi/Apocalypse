import SwiftUI

class LogViewModel: ObservableObject {
    @Published var tradeHistory: [TradeHistory] = []
    @Published var traderProfiles: [TraderProfile] = []
    @Published var selectedTab = 0
    
    init() {
        loadData()
        
        // Listen for trade history updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tradeHistoryUpdated),
            name: NSNotification.Name("TradeHistoryUpdated"),
            object: nil
        )
    }
    
    @objc private func tradeHistoryUpdated() {
        loadData()
    }
    
    func loadData() {
        // Load trade history
        if let historyData = UserDefaults.standard.data(forKey: "tradeHistory"),
           let history = try? JSONDecoder().decode([TradeHistory].self, from: historyData) {
            tradeHistory = history.sorted(by: { $0.date > $1.date })
        }
        
        // Load trader profiles
        if let profilesData = UserDefaults.standard.data(forKey: "traderProfiles"),
           let profiles = try? JSONDecoder().decode([TraderProfile].self, from: profilesData) {
            traderProfiles = profiles
        }
    }
    
    func saveData() {
        if let historyData = try? JSONEncoder().encode(tradeHistory) {
            UserDefaults.standard.set(historyData, forKey: "tradeHistory")
        }
        
        if let profilesData = try? JSONEncoder().encode(traderProfiles) {
            UserDefaults.standard.set(profilesData, forKey: "traderProfiles")
        }
    }
    
    func addTradeHistory(_ history: TradeHistory) {
        tradeHistory.append(history)
        saveData()
    }
    
    func updateTraderProfile(_ profile: TraderProfile) {
        if let index = traderProfiles.firstIndex(where: { $0.id == profile.id }) {
            traderProfiles[index] = profile
        } else {
            traderProfiles.append(profile)
        }
        saveData()
    }
}

struct LogView: View {
    @StateObject private var viewModel = LogViewModel()
    
    // Theme colors
    private let darkGray = Color(red: 0.1, green: 0.1, blue: 0.1)
    private let eerieGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("View", selection: $viewModel.selectedTab) {
                    Text("Trade History").tag(0)
                    Text("Trader Profiles").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if viewModel.selectedTab == 0 {
                    TradeHistoryView(viewModel: viewModel)
                } else {
                    TraderProfilesView(viewModel: viewModel)
                }
            }
            .navigationTitle("Survival Ledger")
//            .background(darkGray.ignoresSafeArea())
        }
    }
}

struct TradeHistoryView: View {
    @ObservedObject var viewModel: LogViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.tradeHistory.sorted(by: { $0.date > $1.date })) { history in
                NavigationLink(destination: TradeHistoryDetailView(history: history, viewModel: viewModel)) {
                    VStack(alignment: .leading) {
                        Text(history.traderAlias)
                            .font(.headline)
                        Text("Traded: \(history.date.formatted())")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct TradeHistoryDetailView: View {
    let history: TradeHistory
    @ObservedObject var viewModel: LogViewModel
    @State private var showingAddToTradersConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("Trader Info")) {
                Text("ID: \(history.traderId)")
                Text("Alias: \(history.traderAlias)")
            }
            
            Section(header: Text("Trade Details")) {
                Text("My Offer: \(history.myOffer)")
                Text("Their Offer: \(history.theirOffer)")
                Text("Date: \(history.date.formatted())")
            }
            
            if !history.tags.isEmpty {
                Section(header: Text("Tags")) {
                    ForEach(history.tags, id: \.self) { tag in
                        Text(tag)
                    }
                }
            }
            
            if !history.notes.isEmpty {
                Section(header: Text("Notes")) {
                    Text(history.notes)
                }
            }
        }
        .navigationTitle("Trade Details")
        .toolbar {
            Button(action: { showingAddToTradersConfirmation = true }) {
                Image(systemName: "person.badge.plus")
            }
        }
        .alert("Add to Traders", isPresented: $showingAddToTradersConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                let newProfile = TraderProfile(
                    id: history.traderId,
                    alias: history.traderAlias,
                    tags: history.tags,
                    notes: history.notes
//                    lastTraded: history.date
                )
                viewModel.updateTraderProfile(newProfile)
            }
        } message: {
            Text("Do you want to add \(history.traderAlias) to your Traders profile list?")
        }
    }
}

struct TraderProfilesView: View {
    @ObservedObject var viewModel: LogViewModel
    @State private var showingAddProfile = false
    
    var body: some View {
        List {
            ForEach(viewModel.traderProfiles.sorted(by: { $0.lastTraded > $1.lastTraded })) { profile in
                NavigationLink(destination: TraderProfileDetailView(profile: profile, viewModel: viewModel)) {
                    VStack(alignment: .leading) {
                        Text(profile.alias)
                            .font(.headline)
                        Text("ID: \(profile.id)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        if !profile.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(profile.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .toolbar {
            Button(action: { showingAddProfile = true }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddProfile) {
            AddTraderProfileView(viewModel: viewModel)
        }
    }
}

struct TraderProfileDetailView: View {
    let profile: TraderProfile
    @ObservedObject var viewModel: LogViewModel
    @State private var newTag = ""
    @State private var notes = ""
    @State private var showingEdit = false
    
    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                Text("ID: \(profile.id)")
                Text("Alias: \(profile.alias)")
                Text("Last Traded: \(profile.lastTraded.formatted())")
            }
            
            Section(header: Text("Tags")) {
                ForEach(profile.tags, id: \.self) { tag in
                    HStack {
                        Text(tag)
                        Spacer()
                        Button(action: {
                            var updatedProfile = profile
                            updatedProfile.tags.removeAll { $0 == tag }
                            viewModel.updateTraderProfile(updatedProfile)
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
                HStack {
                    TextField("Add tag", text: $newTag)
                    Button("Add") {
                        if !newTag.isEmpty {
                            var updatedProfile = profile
                            updatedProfile.tags.append(newTag)
                            viewModel.updateTraderProfile(updatedProfile)
                            newTag = ""
                        }
                    }
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: $notes)
                    .frame(height: 100)
                    .onAppear {
                        notes = profile.notes
                    }
                    .onChange(of: notes) { newValue in
                        var updatedProfile = profile
                        updatedProfile.notes = newValue
                        viewModel.updateTraderProfile(updatedProfile)
                    }
            }
        }
        .navigationTitle("Trader Profile")
    }
}

struct AddTraderProfileView: View {
    @ObservedObject var viewModel: LogViewModel
    @Environment(\.dismiss) var dismiss
    @State private var id = ""
    @State private var alias = ""
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Trader ID", text: $id)
                    TextField("Alias", text: $alias)
                }
                
                Section(header: Text("Tags")) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                    }
                    HStack {
                        TextField("Add tag", text: $newTag)
                        Button("Add") {
                            if !newTag.isEmpty {
                                tags.append(newTag)
                                newTag = ""
                            }
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Trader")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    let profile = TraderProfile(id: id, alias: alias, tags: tags, notes: notes)
                    viewModel.updateTraderProfile(profile)
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    LogView()
}
