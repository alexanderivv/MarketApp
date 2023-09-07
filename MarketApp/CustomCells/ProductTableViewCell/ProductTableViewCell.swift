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
    
    var activityIndicator: UIActivityIndicatorView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupActivityIndicator()
    }
    
    func configure(with product: Product) {
        nameLabel.text = product.title
        descriptionLabel.text = product.description
        categoryLabel.text = product.category
        
        productImageView.image = nil
        
        if let activityIndicator = activityIndicator {
            activityIndicator.startAnimating()
        }
        
        APIManager.shared.fetchImage(urlString: product.image) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    if let self = self, product.title == self.nameLabel.text {
                        self.productImageView.image = image
                        self.activityIndicator?.stopAnimating()
                    }
                }
            case .failure(let error):
                print("Error fetching image: \(error)")
                self?.activityIndicator?.stopAnimating()
            }
        }
    }
    
    private func setupActivityIndicator() {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        addSubview(indicator)
        indicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
        activityIndicator = indicator
    }
}
