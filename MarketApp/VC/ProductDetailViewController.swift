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
    }

    @IBAction func addToCart(_ sender: Any) {
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
    }
}
