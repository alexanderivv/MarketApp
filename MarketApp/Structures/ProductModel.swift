import Foundation

struct Product: Codable, Equatable {
    var id: Int
    var title: String
    var price: Decimal
    var description: String
    var image: String
    var category: String
}
