import SwiftUI

class OfferViewModel: ObservableObject {
    @Published var currentOffer: Offer? {
        didSet {
            // Save to UserDefaults whenever the offer changes
            if let offer = currentOffer {
                if let encoded = try? JSONEncoder().encode(offer) {
                    UserDefaults.standard.set(encoded, forKey: "currentOffer")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "currentOffer")
            }
        }
    }
    
    init() {
        // Load current offer from UserDefaults
        if let offerData = UserDefaults.standard.data(forKey: "currentOffer"),
           let offer = try? JSONDecoder().decode(Offer.self, from: offerData) {
            currentOffer = offer
        }
    }
    
    func updateOffer(haveQuantity: Int, haveName: String, needQuantity: Int, needName: String) {
        let newOffer = Offer(
            survivorId: UserDefaults.standard.string(forKey: "deviceID") ?? "",
            haveQuantity: haveQuantity,
            haveName: haveName,
            needQuantity: needQuantity,
            needName: needName
        )
        currentOffer = newOffer
    }
    
    func clearOffer() {
        currentOffer = nil
    }
} 