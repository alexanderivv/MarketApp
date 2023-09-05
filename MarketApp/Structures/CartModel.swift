import Foundation

struct Cart: Codable {
    let id: Int
    let userId: Int
    let date: String
    let products: [CartItem]
}

struct CartItem: Codable {
    let productId: Int
    let quantity: Int
}
