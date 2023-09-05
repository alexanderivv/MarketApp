import UIKit
import CoreLocation

class MainViewController: UIViewController {

    var products = [Product]()
    var selectedCategory: String?
    var filteredProducts: [Product] = []
    var productIndexes: [Int: Int] = [:]
    private var activityIndicator: UIActivityIndicatorView?

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        openMap()
    }
    
    @IBAction func selectCategoryButton(_ sender: UIBarButtonItem) {
        selectCategory()
    }

    func fetchProducts() {
        activityIndicator?.startAnimating()

        ProductManager.shared.fetchProducts { [weak self] result in
            switch result {
            case .success(let products):
                DispatchQueue.main.async {
                    self?.products = products
                    
                    if let selectedCategory = self?.selectedCategory {
                        self?.filteredProducts = products.filter { $0.category == selectedCategory }
                    } else {
                        self?.filteredProducts = products
                    }
                    
                    self?.productIndexes.removeAll()
                    for (index, product) in self?.filteredProducts.enumerated() ?? [].enumerated() {
                        self?.productIndexes[product.id] = index
                    }
                    
                    self?.tableView.reloadData()
                    self?.activityIndicator?.stopAnimating()
                }
            case .failure(let error):
                print("Error fetching products: \(error)")
                DispatchQueue.main.async {
                    self?.activityIndicator?.stopAnimating()
                }
            }
        }
    }
    
    func updateLocationButtonText() {
        if let currentUser = UserManager.shared.currentUser {
            DispatchQueue.main.async {
                self.locationButton.title = currentUser.address.city
            }
        }
    }
    
    private func openMap() {
        if let city = locationButton.title, locationButton.title != "Локация" {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(city) { [weak self] (placemarks, error) in
                if let _ = placemarks?.first?.location {
                    let mapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                    mapVC.selectedCity = city
                    self?.navigationController?.pushViewController(mapVC, animated: true)
                } else {
                    let alertController = UIAlertController(title: "Некорректный город", message: "Извините, такого города нет в базе данных 😢", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func selectCategory() {
        let alertController = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        
        for category in ProductManager.shared.categories {
            alertController.addAction(UIAlertAction(title: category, style: .default, handler: { [weak self] _ in
                self?.selectedCategory = category
                self?.fetchProducts()
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "All Categories", style: .default, handler: { [weak self] _ in
            self?.selectedCategory = nil
            self?.fetchProducts()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive

        tableView.register(ProductTableViewCell.nib(), forCellReuseIdentifier: ProductTableViewCell.identifier)

        setupActivityIndicator()
        selectedCategory = nil
        fetchProducts()
    }
    
    private func setupActivityIndicator() {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.center = view.center
            indicator.hidesWhenStopped = true
            view.addSubview(indicator)
            activityIndicator = indicator
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as! ProductTableViewCell
        let product = filteredProducts[indexPath.row]
        cell.configure(with: product)
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedProduct = filteredProducts[indexPath.row]

        if let productDetailVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController {
            productDetailVC.product = selectedProduct
            let navController = UINavigationController(rootViewController: productDetailVC)
            navController.modalPresentationStyle = .pageSheet
            present(navController, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            if let selectedCategory = selectedCategory {
                filteredProducts = products.filter { $0.category == selectedCategory }
            } else {
                filteredProducts = products
            }
        } else {
            filteredProducts = products.filter { product in
                let titleMatch = product.title.localizedCaseInsensitiveContains(searchText)
                let descriptionMatch = product.description.localizedCaseInsensitiveContains(searchText)
                if let selectedCategory = selectedCategory {
                    return (titleMatch || descriptionMatch) && product.category == selectedCategory
                } else {
                    return titleMatch || descriptionMatch
                }
            }
        }
        tableView.reloadData()
    }
}
