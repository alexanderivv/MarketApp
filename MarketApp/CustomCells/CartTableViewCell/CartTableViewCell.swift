import UIKit

class CartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameProductsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let identifier = "CartTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "CartTableViewCell", bundle: nil)
    }
    
    func configure(with cart: Cart) {
        dateLabel.text = FormatterManager.shared.convertDateString(cart.date)
        
        var productsText = ""
        
        for cartItem in cart.products {
            APIManager.shared.fetchProductInfo(for: cartItem.productId) { result in
                switch result {
                case .success(let product):
                    let productText = "• \(product.title)\n"
                    productsText += productText
                    
                    DispatchQueue.main.async {
                        self.nameProductsLabel.text = productsText
                    }
                case .failure(let error):
                    print("Error fetching product info: \(error)")
                }
            }
        }
    }
}
