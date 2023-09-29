import UIKit

class TabBarController: UITabBarController {
    
    var mainViewController: MainViewController?
    var isLoggedIn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartBadge), name: NSNotification.Name("CartItemUpdatedNotification"), object: nil)
        
        initializeMainViewController()
    }
    
    func initializeMainViewController() {
        if let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            mainViewController = mainVC
            
            if let navigationController = viewControllers?[0] as? UINavigationController {
                navigationController.setViewControllers([mainVC], animated: false)
            }
        }
    }
    
    func updateTabBar(isLoggedIn: Bool) {
        if isLoggedIn {
            if let profileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
                if let profileNavigationController = viewControllers?[2] as? UINavigationController {
                    profileNavigationController.setViewControllers([profileViewController], animated: true)
                }
            }
            if let user = UserManager.shared.currentUser {
                if let savedCart = UserManager.shared.loadUserCart(forUser: user.id) {
                    CartManager.shared.updateCart(with: [savedCart])
                    UserManager.shared.saveUserCart(CartManager.shared.getCart(), forUser: user.id)
                }
                self.mainViewController?.updateLocationButtonText()
            }
        } else {
            if let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                if let navigationController = viewControllers?[2] as? UINavigationController {
                    navigationController.setViewControllers([loginViewController], animated: true)
                }
            }
            UserManager.shared.currentUser = nil
            ThemeManager.shared.applyTheme(0)
            CartManager.shared.clearCart()
            CartManager.shared.updateCartView()
            mainViewController?.locationButton.title = nil
        }
        self.isLoggedIn = isLoggedIn
    }
    
    @objc private func updateCartBadge() {
        if let tabBarItems = tabBar.items {
            let cartTabBarItem = tabBarItems[1]
            let numberOfItemsInCart = CartManager.shared.getCartItems().count
            cartTabBarItem.badgeValue = numberOfItemsInCart > 0 ? "\(numberOfItemsInCart)" : nil
        }
    }
}
