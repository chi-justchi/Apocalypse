import Foundation

struct Trade: Identifiable, Codable {
    let id: UUID
    let initiatorId: String
    let receiverId: String
    let initiatorOffer: Offer
    let receiverOffer: Offer
    let passcode: String
    let status: TradeStatus
    let timestamp: Date
    
    init(id: UUID = UUID(), 
         initiatorId: String, 
         receiverId: String, 
         initiatorOffer: Offer, 
         receiverOffer: Offer, 
         passcode: String = String(Int.random(in: 1000...9999))) {
        self.id = id
        self.initiatorId = initiatorId
        self.receiverId = receiverId
        self.initiatorOffer = initiatorOffer
        self.receiverOffer = receiverOffer
        self.passcode = passcode
        self.status = .pending
        self.timestamp = Date()
    }
}

enum TradeStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case completed
    case failed
}