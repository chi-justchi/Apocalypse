import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var nearbyOffers: [Offer] = []
    @Published var inventory: [InventoryItem] = []
    @Published var username: String = "Survivor"
    
    init() {
        // Load saved data
        loadData()
    }
    
    func loadData() {
        // Load username from UserDefaults
        username = UserDefaults.standard.string(forKey: "username") ?? "Survivor"
        
        // Load inventory
        if let inventoryData = UserDefaults.standard.data(forKey: "inventory"),
           let items = try? JSONDecoder().decode([InventoryItem].self, from: inventoryData) {
            inventory = items
        }
    }
    
    func addInventoryItem(name: String, quantity: Int) {
        let newItem = InventoryItem(name: name, quantity: quantity)
        inventory.append(newItem)
        saveInventory()
    }
    
    func removeInventoryItem(at index: Int) {
        inventory.remove(at: index)
        saveInventory()
    }
    
    private func saveInventory() {
        if let encoded = try? JSONEncoder().encode(inventory) {
            UserDefaults.standard.set(encoded, forKey: "inventory")
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var offerViewModel = OfferViewModel()
    @State private var showingEditOffer = false
    @State private var showingInventory = false
    
    // Theme colors
    private let darkGray = Color(red: 0.1, green: 0.1, blue: 0.1)
    private let eerieGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    private let bloodRed = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    var body: some View {
        NavigationView {
            ZStack {
                darkGray.ignoresSafeArea()
                // Background Image
//                Image("BackgroundPostApo")
//                    .resizable()
//                    .scaledToFill()
//                    .ignoresSafeArea()
//                    .opacity(0.3) // Adjust opacity to make it less distracting
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome Section
                        VStack(alignment: .leading) {
                            Text("Welcome back,")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Chip")
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        
                        // Current Offer Section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Your Current Offer")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { showingEditOffer = true }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(eerieGreen)
                                }
                            }
                            
                            if let offer = offerViewModel.currentOffer {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Have: \(offer.haveQuantity) \(offer.haveName)")
                                        .foregroundColor(.white)
                                    Text("Need: \(offer.needQuantity) \(offer.needName)")
                                        .foregroundColor(.white)
                                }
                            } else {
                                Text("No current offer")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Nearby Offers Section
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("Nearby Survivors")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                            
//                            if viewModel.nearbyOffers.isEmpty {
//                                Text("No nearby offers found")
//                                    .foregroundColor(.gray)
//                            } else {
//                                ForEach(viewModel.nearbyOffers) { offer in
//                                    VStack(alignment: .leading, spacing: 5) {
//                                        Text("Have: \(offer.haveQuantity) \(offer.haveName)")
//                                            .foregroundColor(.white)
//                                        Text("Need: \(offer.needQuantity) \(offer.needName)")
//                                            .foregroundColor(.white)
//                                    }
//                                    .padding()
//                                    .background(Color(red: 0.2, green: 0.2, blue: 0.2))
//                                    .cornerRadius(10)
//                                }
//                            }
//                        }
//                        .padding()
                        
                        // Inventory Preview
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("My Inventory")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { showingInventory = true }) {
                                    Text("View All")
                                        .foregroundColor(eerieGreen)
                                }
                            }
                            
                            if viewModel.inventory.isEmpty {
                                Text("No items in inventory")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(viewModel.inventory.prefix(3)) { item in
                                    HStack {
                                        Text("\(item.name) x\(item.quantity)")
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditOffer) {
                EditOfferView(offerViewModel: offerViewModel)
            }
            .sheet(isPresented: $showingInventory) {
                InventoryView(viewModel: viewModel)
            }
        }
    }
}

struct EditOfferView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var offerViewModel: OfferViewModel
    @State private var haveQuantity = ""
    @State private var haveName = ""
    @State private var needQuantity = ""
    @State private var needName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("What you have")) {
                    HStack {
                        TextField("Quantity", text: $haveQuantity)
                            .keyboardType(.numberPad)
                        TextField("Item name", text: $haveName)
                    }
                }
                
                Section(header: Text("What you need")) {
                    HStack {
                        TextField("Quantity", text: $needQuantity)
                            .keyboardType(.numberPad)
                        TextField("Item name", text: $needName)
                    }
                }
            }
            .navigationTitle("Edit Offer")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if let haveQty = Int(haveQuantity),
                       let needQty = Int(needQuantity),
                       !haveName.isEmpty,
                       !needName.isEmpty {
                        offerViewModel.updateOffer(
                            haveQuantity: haveQty,
                            haveName: haveName,
                            needQuantity: needQty,
                            needName: needName
                        )
                        dismiss()
                    }
                }
            )
            .onAppear {
                if let offer = offerViewModel.currentOffer {
                    haveQuantity = String(offer.haveQuantity)
                    haveName = offer.haveName
                    needQuantity = String(offer.needQuantity)
                    needName = offer.needName
                }
            }
        }
    }
}

struct InventoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    @State private var newItemName = ""
    @State private var newItemQuantity = ""
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.inventory) { item in
                    HStack {
                        Text("\(item.name) x\(item.quantity)")
                        Spacer()
                        Button(action: {
                            if let index = viewModel.inventory.firstIndex(where: { $0.id == item.id }) {
                                viewModel.removeInventoryItem(at: index)
                            }
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Button(action: { showingAddItem = true }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Item")
                    }
                }
            }
            .navigationTitle("Inventory")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .sheet(isPresented: $showingAddItem) {
                AddItemView(viewModel: viewModel)
            }
        }
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    @State private var name = ""
    @State private var quantity = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $name)
                TextField("Quantity", text: $quantity)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add Item")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if let quantity = Int(quantity) {
                        viewModel.addInventoryItem(name: name, quantity: quantity)
                        dismiss()
                    }
                }
            )
        }
    }
}

#Preview {
    HomeView()
} 
