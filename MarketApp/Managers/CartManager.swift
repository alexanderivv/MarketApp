import Foundation

class CartManager {
    static let shared = CartManager()
    
    private var cartItems: [Product] = []
    
    func addToCart(_ product: Product) {
        cartItems.append(product)
    }
    
    func updateCart(with userCarts: [Cart]) {
        for cart in userCarts {
            for cartItem in cart.products {
                if let product = ProductManager.shared.products.first(where: { $0.id == cartItem.productId }) {
                   addToCart(product)
                        }
                    }
                }
            }
    
    func removeFromCart(_ product: Product) {
        if let index = cartItems.firstIndex(of: product) {
            cartItems.remove(at: index)
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    func getCartItems() -> [Product] {
        return cartItems
    }
    
    func totalCartPrice() -> Decimal {
        return cartItems.reduce(Decimal()) { $0 + $1.price }
    }
    
    func saveCart(_ cart: Cart, forUser userId: Int) {
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(cart) {
                UserDefaults.standard.set(encodedData, forKey: "Cart_\(userId)")
            }
        }
    
    func loadCart(forUser userId: Int) -> Cart? {
            if let savedData = UserDefaults.standard.data(forKey: "Cart_\(userId)"),
                let cart = try? JSONDecoder().decode(Cart.self, from: savedData) {
                return cart
            }
            return nil
        }
    
    func setCart(_ cart: Cart) {
            cartItems = cart.products.map { cartItem in
                if let product = ProductManager.shared.products.first(where: { $0.id == cartItem.productId }) {
                    return product
                }
                return nil
            }.compactMap { $0 }
        }
    
    func getCart() -> Cart {
            let cartItems = self.cartItems.map { CartItem(productId: $0.id, quantity: 1) }
            return Cart(id: 0, userId: 0, date: "", products: cartItems)
    }
    
    func updateCartView() {
        NotificationCenter.default.post(name: NSNotification.Name("CartUpdatedNotification"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("CartItemUpdatedNotification"), object: nil)
    }
}
