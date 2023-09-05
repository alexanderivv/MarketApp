import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var themeControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func themeControlChanged(_ sender: Any) {
    }
    
    @IBAction func passwordChange(_ sender: Any) {
    }
    
    @IBAction func logOutButton(_ sender: Any) {
    }
    
    @IBAction func deleteProfile(_ sender: Any) {
    }
}
