import Foundation

struct Survivor: Identifiable, Codable {
    let id: String // Device ID
    var alias: String
    var trustScore: Double
    var reputationTags: [String]
    var lastSeen: Date
    
    init(id: String, alias: String = "Unknown Survivor", trustScore: Double = 0.0, reputationTags: [String] = []) {
        self.id = id
        self.alias = alias
        self.trustScore = trustScore
        self.reputationTags = reputationTags
        self.lastSeen = Date()
    }
}