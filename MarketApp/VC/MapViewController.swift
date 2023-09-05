import MapKit
import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var selectedCity: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
