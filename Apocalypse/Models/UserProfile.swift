import Foundation

struct UserProfile: Codable {
    var alias: String
    var publicKey: String
    var tagline: String
    var totalTrades: Int
    
    init(alias: String = "", publicKey: String = "", tagline: String = "", totalTrades: Int = 0) {
        self.alias = alias
        self.publicKey = publicKey
        self.tagline = tagline
        self.totalTrades = totalTrades
    }
}