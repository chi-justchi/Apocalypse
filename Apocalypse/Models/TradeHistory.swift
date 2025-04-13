import Foundation

struct TradeHistory: Identifiable, Codable {
    let id: String
    let traderId: String
    let traderAlias: String
    let myOffer: String
    let theirOffer: String
    let date: Date
    var tags: [String]
    var notes: String
    
    init(traderId: String, traderAlias: String, myOffer: String, theirOffer: String, tags: [String] = [], notes: String = "") {
        self.id = UUID().uuidString
        self.traderId = traderId
        self.traderAlias = traderAlias
        self.myOffer = myOffer
        self.theirOffer = theirOffer
        self.date = Date()
        self.tags = tags
        self.notes = notes
    }
}

struct TraderProfile: Identifiable, Codable {
    let id: String
    let alias: String
    var tags: [String]
    var notes: String
    var lastTraded: Date
    
    init(id: String, alias: String, tags: [String] = [], notes: String = "") {
        self.id = id
        self.alias = alias
        self.tags = tags
        self.notes = notes
        self.lastTraded = Date()
    }
}