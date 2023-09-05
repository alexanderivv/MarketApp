import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
    }
    
    @IBAction func selectCategoryButton(_ sender: UIBarButtonItem) {
    }
}
