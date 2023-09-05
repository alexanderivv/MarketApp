import Foundation

struct User: Codable {
    let id: Int
    let email: String
    let username: String
    var password: String
    let name: Name
    let address: Address
    let phone: String
}

struct Name: Codable {
    let firstname: String
    let lastname: String
}

struct Address: Codable {
    let city: String
    let street: String
    let number: Int
    let zipcode: String
    let geolocation: Geolocation
}

struct Geolocation: Codable {
    let lat: String
    let long: String
}
