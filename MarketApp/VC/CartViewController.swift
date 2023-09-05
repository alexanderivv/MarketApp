import UIKit
import PassKit

class CartViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func payWithApplePayButton(_ sender: Any) {
    }
    
    @IBAction func removeAllButton(_ sender: Any) {
    }
}
