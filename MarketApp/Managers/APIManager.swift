import UIKit

class APIManager {
    
    static let shared = APIManager()

    func fetchImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "com.example.apiManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image URL"])
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                let error = NSError(domain: "com.example.apiManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to image"])
                completion(.failure(error))
                return
            }

            completion(.success(image))
        }.resume()
    }
    
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let url = URL(string: "https://fakestoreapi.com/users") else {
            let error = NSError(domain: "com.example.apiManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let userData = data else {
                let error = NSError(domain: "com.example.apiManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }

            do {
                let users = try JSONDecoder().decode([User].self, from: userData)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    func fetchUserOrderHistory(for userId: Int, completion: @escaping (Result<[Cart], Error>) -> Void) {
        let urlString = "https://fakestoreapi.com/carts/user/\(userId)"
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "com.example.apiManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let userCarts = try decoder.decode([Cart].self, from: data)
                    completion(.success(userCarts))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchProductInfo(for productID: Int, completion: @escaping (Result<Product, Error>) -> Void) {
        guard let productURL = URL(string: "https://fakestoreapi.com/products/\(productID)") else {
            let error = NSError(domain: "com.example.apiManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: productURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "com.example.apiManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let product = try decoder.decode(Product.self, from: data)
                completion(.success(product))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
