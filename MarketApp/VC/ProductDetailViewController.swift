import UIKit

class ProductDetailViewController: UIViewController {

    var product: Product?
    
    @IBOutlet weak var nameProductLabel: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var descriptionProduct: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction func addToCart(_ sender: Any) {
        if let product = product {
            CartManager.shared.addToCart(product)
            
            if let user = UserManager.shared.currentUser {
                UserManager.shared.saveUserCart(CartManager.shared.getCart(), forUser: user.id)
            }
            
            let alertController = UIAlertController(title: "Товар добавлен в корзину", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            
            CartManager.shared.updateCartView()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        if let product = product {
            nameProductLabel.text = product.title
            descriptionProduct.text = product.description
            priceLabel.text = "Price: \(FormatterManager.shared.formattedPrice(for: product.price))$"
            categoryLabel.text = product.category
            
            APIManager.shared.fetchImage(urlString: product.image) { [weak self] result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self?.imageProduct.image = image
                    }
                case .failure(let error):
                    print("Error fetching image: \(error)")
                }
            }
        }
    }
}
