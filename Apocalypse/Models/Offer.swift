import Foundation

struct Offer: Identifiable, Codable {
    let id: String
    let survivorId: String
    let haveQuantity: Int
    let haveName: String
    let needQuantity: Int
    let needName: String
    
    init(survivorId: String, haveQuantity: Int, haveName: String, needQuantity: Int, needName: String) {
        self.id = UUID().uuidString
        self.survivorId = survivorId
        self.haveQuantity = haveQuantity
        self.haveName = haveName
        self.needQuantity = needQuantity
        self.needName = needName
    }
} 