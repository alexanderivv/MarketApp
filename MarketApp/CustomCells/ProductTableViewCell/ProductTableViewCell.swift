import UIKit

class ProductTableViewCell: UITableViewCell {
    
    static let identifier = "ProductTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ProductTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!

    func configure(with product: Product) {
        nameLabel.text = product.title
        
        APIManager.shared.fetchImage(urlString: product.image) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    if let self = self, product.title == self.nameLabel.text {
                        self.productImageView.image = image
                    }
                }
            case .failure(let error):
                print("Error fetching image: \(error)")
            }
        }
        
        descriptionLabel.text = product.description
        categoryLabel.text = product.category
    }
}
