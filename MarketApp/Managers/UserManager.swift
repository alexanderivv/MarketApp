import Foundation

class UserManager {
    static let shared = UserManager()

    private var users: [User] = []
    var currentUser: User?

    private init() {
        fetchUsers()
    }

    func fetchUsers() {
        if let encodedData = UserDefaults.standard.data(forKey: "UsersKey"),
           let users = try? PropertyListDecoder().decode([User].self, from: encodedData) {
            self.users = users
        } else {
            APIManager.shared.fetchUsers { result in
                switch result {
                case .success(let users):
                    self.users = users
                case .failure(let error):
                    print("Error fetching users: \(error)")
                }
            }
        }
    }

    func authenticateUser(username: String, password: String) -> User? {
        return users.first { $0.username == username && $0.password == password }
    }

    func updateUser(_ updatedUser: User) {
        if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
            users[index] = updatedUser
            saveUsersToUserDefaults()
        }
    }
    
    func removeUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users.remove(at: index)
            saveUsersToUserDefaults()
        }
    }
    
    func saveUserCart(_ cart: Cart, forUser userId: Int) {
        CartManager.shared.saveCart(cart, forUser: userId)
    }
    
    func loadUserCart(forUser userId: Int) -> Cart? {
        return CartManager.shared.loadCart(forUser: userId)
    }

    private func saveUsersToUserDefaults() {
        if let encodedData = try? PropertyListEncoder().encode(users) {
            UserDefaults.standard.set(encodedData, forKey: "UsersKey")
        }
    }
}
