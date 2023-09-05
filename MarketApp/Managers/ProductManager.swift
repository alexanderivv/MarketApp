import Foundation

class ProductManager {
    static let shared = ProductManager()

    var products: [Product] = []
    var categories: [String] = []

    private init() {
        fetchProducts { result in
            switch result {
            case .success(let products):
                self.products = products
                self.categories = Array(Set(products.map { $0.category }))
            case .failure(let error):
                print("Error fetching products: \(error)")
            }
        }
    }

    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        let urlString = "https://fakestoreapi.com/products"
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "com.example.productManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "com.example.productManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }

            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                self.products = products
                completion(.success(products))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getCategories() -> [String] {
        return categories
    }
}
