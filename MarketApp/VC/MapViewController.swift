import MapKit
import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var selectedCity: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let city = selectedCity {
            showMapFor(city: city)
        }
    }
    
    func showMapFor(city: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { [weak self] (placemarks, error) in
            if let location = placemarks?.first?.location {
                let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1500000, longitudinalMeters: 1500000)
                self?.mapView.setRegion(coordinateRegion, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = city
                self?.mapView.addAnnotation(annotation)
            } else if let error = error {
                print("Geocoding error: \(error)")
            }
        }
    }
}
