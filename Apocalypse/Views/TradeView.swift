import SwiftUI
import MultipeerConnectivity

class TradeViewModel: NSObject, ObservableObject {
    @Published var currentOffer: Offer?
    @Published var nearbySurvivors: [Survivor] = []
    @Published var nearbyOffers: [Offer] = []
    @Published var activeTrades: [Trade] = []
    @Published var isScanning = false
    @Published var selectedSurvivor: Survivor?
    @Published var showingTradeConfirmation = false
    @Published var showingTradeCode = false
    @Published var tradeCode = ""
    @Published var showingDeclineMessage = false
    @Published var showingSuccessMessage = false
    @Published var acceptedSurvivor: Survivor?
    @Published var showingIncomingTrade = false
    @Published var incomingTradeSurvivor: Survivor?
    @Published var incomingTradeOffer: Offer?
    
    private var peerID: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser
    
    override init() {
        // Initialize Multipeer Connectivity
        let deviceID = UserDefaults.standard.string(forKey: "deviceID") ?? UUID().uuidString
        peerID = MCPeerID(displayName: deviceID)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "boom-trade")
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "boom-trade")
        
        super.init()
        
        // Set delegates
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        
        // Load current offer
        if let offerData = UserDefaults.standard.data(forKey: "currentOffer"),
           let offer = try? JSONDecoder().decode(Offer.self, from: offerData) {
            currentOffer = offer
        }
        
        // Start scanning and generate survivors
        startScanning()
    }
    
    func startScanning() {
        isScanning = true
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        
        // Generate initial survivors and offers
        generateSurvivorsAndOffers()
    }
    
    func stopScanning() {
        isScanning = false
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        nearbySurvivors.removeAll()
        nearbyOffers.removeAll()
    }
    
    private func generateSurvivorsAndOffers() {
        nearbySurvivors.removeAll()
        nearbyOffers.removeAll()
        
        // Generate 3-5 random survivors
        let survivorCount = Int.random(in: 3...5)
        
        // First, generate a survivor with a matching offer if we have a current offer
        if let currentOffer = currentOffer {
            let matchingSurvivor = createMatchingSurvivor()
            let matchingOffer = createMatchingOffer(for: currentOffer, survivorId: matchingSurvivor.id)
            nearbySurvivors.append(matchingSurvivor)
            nearbyOffers.append(matchingOffer)
        }
        
        // Then generate the remaining survivors and offers
        for _ in 0..<(survivorCount - 1) {
            let survivor = createRandomSurvivor()
            let offer = createRandomOffer(survivorId: survivor.id)
            nearbySurvivors.append(survivor)
            nearbyOffers.append(offer)
        }
    }
    
    private func createMatchingSurvivor() -> Survivor {
        let mockAliases = ["Scavenger", "Wanderer", "Nomad", "Survivor", "Trader"]
        let mockTags = [["Trusted"], ["New"], ["Risky"], ["Reliable"], ["Unknown"]]
        
        return Survivor(
            id: UUID().uuidString,
            alias: mockAliases.randomElement()!,
            trustScore: Double.random(in: 7...10), // Higher trust score for matching offers
            reputationTags: mockTags.randomElement()!
        )
    }
    
    private func createMatchingOffer(for offer: Offer, survivorId: String) -> Offer {
        return Offer(
            survivorId: survivorId,
            haveQuantity: offer.needQuantity,
            haveName: offer.needName,
            needQuantity: offer.haveQuantity,
            needName: offer.haveName
        )
    }
    
    private func createRandomSurvivor() -> Survivor {
        let mockAliases = ["Scavenger", "Wanderer", "Nomad", "Survivor", "Trader"]
        let mockTags = [["Trusted"], ["New"], ["Risky"], ["Reliable"], ["Unknown"]]
        
        return Survivor(
            id: UUID().uuidString,
            alias: mockAliases.randomElement()!,
            trustScore: Double.random(in: 0...10),
            reputationTags: mockTags.randomElement()!
        )
    }
    
    private func createRandomOffer(survivorId: String) -> Offer {
        let mockOffers = [
            Offer(survivorId: survivorId, haveQuantity: 5, haveName: "Water", needQuantity: 3, needName: "Food"),
            Offer(survivorId: survivorId, haveQuantity: 2, haveName: "Medicine", needQuantity: 10, needName: "Ammo"),
            Offer(survivorId: survivorId, haveQuantity: 1, haveName: "Fuel", needQuantity: 2, needName: "Tools"),
            Offer(survivorId: survivorId, haveQuantity: 3, haveName: "Food", needQuantity: 5, needName: "Water"),
            Offer(survivorId: survivorId, haveQuantity: 10, haveName: "Ammo", needQuantity: 2, needName: "Medicine")
        ]
        
        return mockOffers.randomElement()!
    }
    
    func getOffer(for survivor: Survivor) -> Offer? {
        return nearbyOffers.first { $0.survivorId == survivor.id }
    }
    
    func initiateTrade(with survivor: Survivor) {
        guard let myOffer = currentOffer,
              let theirOffer = getOffer(for: survivor) else { return }
        
        let trade = Trade(
            initiatorId: peerID.displayName,
            receiverId: survivor.id,
            initiatorOffer: myOffer,
            receiverOffer: theirOffer
        )
        
        // Show incoming trade notification to the other person
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.incomingTradeSurvivor = survivor
            self.incomingTradeOffer = myOffer
            self.showingIncomingTrade = true
        }
    }
    
    func acceptIncomingTrade() {
        guard let survivor = incomingTradeSurvivor,
              let offer = incomingTradeOffer else { return }
        
        showingIncomingTrade = false
        
        // Generate and show the passcode
        tradeCode = String(format: "%04d", Int.random(in: 0...9999))
        showingTradeCode = true
        
        // Hide the passcode after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.showingTradeCode = false
            self.incomingTradeSurvivor = nil
            self.incomingTradeOffer = nil
        }
    }
    
    func declineIncomingTrade() {
        showingIncomingTrade = false
        showingDeclineMessage = true
        
        // Hide the decline message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showingDeclineMessage = false
            self.incomingTradeSurvivor = nil
            self.incomingTradeOffer = nil
        }
    }
}

extension TradeViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // Handle peer connection state changes
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Handle received trade requests
        if let trade = try? JSONDecoder().decode(Trade.self, from: data) {
            DispatchQueue.main.async {
                self.activeTrades.append(trade)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension TradeViewModel: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension TradeViewModel: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Handle found peers
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // Handle lost peers
    }
}

struct TradeEditOfferView: View {
    @ObservedObject var offerViewModel: OfferViewModel
    @Environment(\.dismiss) var dismiss
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

struct TradeView: View {
    @StateObject private var viewModel = TradeViewModel()
    @StateObject private var offerViewModel = OfferViewModel()
    @State private var showingEditOffer = false
    
    // Theme colors
    private let lightGray = Color(red: 0.2, green: 0.2, blue: 0.2)
    private let eerieGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Offer Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Current Offer")
                            .font(.headline)
                            .foregroundColor(eerieGreen)
                        
                        if let offer = offerViewModel.currentOffer {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Have: \(offer.haveQuantity) \(offer.haveName)")
                                    .foregroundColor(.white)
                                Text("Need: \(offer.needQuantity) \(offer.needName)")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(8)
                        } else {
                            VStack(spacing: 16) {
                                Text("No current offer")
                                    .foregroundColor(.gray)
                                Button(action: { showingEditOffer = true }) {
                                    Text("Create Offer")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(eerieGreen)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Nearby Survivors Section
                    if viewModel.currentOffer != nil {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Nearby Survivors")
                                .font(.headline)
                                .foregroundColor(eerieGreen)
                            
                            if viewModel.nearbySurvivors.isEmpty {
                                Text("No nearby survivors found")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(viewModel.nearbySurvivors) { survivor in
                                    SurvivorCard(
                                        survivor: survivor,
                                        offer: viewModel.getOffer(for: survivor)
                                    ) { selected in
                                        viewModel.selectedSurvivor = selected
                                        viewModel.showingTradeConfirmation = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(lightGray.ignoresSafeArea())
            .navigationTitle("Your current trade")
            .sheet(isPresented: $showingEditOffer) {
                TradeEditOfferView(offerViewModel: offerViewModel)
            }
            .sheet(isPresented: $viewModel.showingTradeConfirmation) {
                if let survivor = viewModel.selectedSurvivor,
                   let theirOffer = viewModel.getOffer(for: survivor) {
                    TradeConfirmationView(survivor: survivor, theirOffer: theirOffer, viewModel: viewModel)
                }
            }
            .overlay {
                if viewModel.showingTradeCode {
                    TradeCodeView(code: viewModel.tradeCode)
                }
                
                if viewModel.showingDeclineMessage {
                    DeclineMessageView()
                }
                
                if viewModel.showingSuccessMessage, let survivor = viewModel.acceptedSurvivor {
                    SuccessMessageView(survivor: survivor)
                }
                
                if viewModel.showingIncomingTrade, 
                   let survivor = viewModel.incomingTradeSurvivor,
                   let offer = viewModel.incomingTradeOffer {
                    IncomingTradeView(
                        survivor: survivor,
                        offer: offer,
                        onAccept: { viewModel.acceptIncomingTrade() },
                        onDecline: { viewModel.declineIncomingTrade() }
                    )
                }
            }
        }
    }
}

struct SurvivorCard: View {
    let survivor: Survivor
    let offer: Offer?
    let onTrade: (Survivor) -> Void
    
    private let eerieGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(survivor.alias)
                        .font(.headline)
                    Text("Trust Score: \(Int(survivor.trustScore * 10))%")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if !survivor.reputationTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(survivor.reputationTags, id: \.self) { tag in
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
            
            if let offer = offer {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Their Offer")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Have")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(offer.haveQuantity) \(offer.haveName)")
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Need")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(offer.needQuantity) \(offer.needName)")
                        }
                    }
                }
            }
            
            Button(action: { onTrade(survivor) }) {
                Text("Initiate Trade")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(eerieGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(8)
    }
}

struct TradeConfirmationView: View {
    let survivor: Survivor
    let theirOffer: Offer
    @ObservedObject var viewModel: TradeViewModel
    @Environment(\.dismiss) var dismiss
    
    private let eerieGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("Confirm Trade")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("with \(survivor.alias)")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.top)
                
                if let myOffer = viewModel.currentOffer {
                    VStack(spacing: 16) {
                        TradeDetailCard(
                            title: "You Give",
                            quantity: myOffer.haveQuantity,
                            item: myOffer.haveName
                        )
                        TradeDetailCard(
                            title: "You Receive",
                            quantity: theirOffer.haveQuantity,
                            item: theirOffer.haveName
                        )
                    }
                    .padding()
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.initiateTrade(with: survivor)
                    dismiss()
                }) {
                    Text("Confirm Trade")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(eerieGreen)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
}

struct TradeDetailCard: View {
    let title: String
    let quantity: Int
    let item: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("\(quantity) \(item)")
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(8)
    }
}

struct TradeCodeView: View {
    let code: String
    private let eerieGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Trade Code")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Share this code with the other survivor")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(code)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(eerieGreen)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                
                Text("Waiting for confirmation...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
            .cornerRadius(20)
            .padding()
        }
    }
}

struct DeclineMessageView: View {
    private let bloodRed = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(bloodRed)
                
                Text("Trade Declined")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("The other survivor declined your offer")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
            .cornerRadius(20)
            .padding()
        }
    }
}

struct SuccessMessageView: View {
    let survivor: Survivor
    private let eerieGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(eerieGreen)
                
                Text("Trade Accepted!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(survivor.alias) has accepted your offer")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Trade has been added to your history")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
            .cornerRadius(20)
            .padding()
        }
    }
}

struct IncomingTradeView: View {
    let survivor: Survivor
    let offer: Offer
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    private let eerieGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    private let bloodRed = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Trade icon
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 20))
                    .foregroundColor(eerieGreen)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trade Request from \(survivor.alias)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Offering: \(offer.haveQuantity) \(offer.haveName)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 8) {
                    Button(action: onAccept) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(eerieGreen)
                    }
                    
                    Button(action: onDecline) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(bloodRed)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.top, 0)
        .position(x: UIScreen.main.bounds.width / 2, y: 50)
        .transition(.move(edge: .top))
        .animation(.spring(), value: true)
    }
}

#Preview {
    TradeView()
}
