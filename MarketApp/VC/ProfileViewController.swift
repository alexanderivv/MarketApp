import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var themeControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var user = UserManager.shared.currentUser
    var userCarts: [Cart] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction func themeControlChanged(_ sender: Any) {
        themeChange()
    }
    
    @IBAction func passwordChange(_ sender: Any) {
        showChangePasswordAlert()
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        showLogOutAlert()
    }
    
    @IBAction func deleteProfile(_ sender: Any) {
        showDeleteProfileAlert()
    }
    
    func loadUserOrderHistory() {
        guard let userId = user?.id else {
            return
        }

        APIManager.shared.fetchUserOrderHistory(for: userId) { [weak self] result in
            switch result {
            case .success(let userCarts):
                self?.userCarts = userCarts

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.updateTableViewVisibility()
                    if UserManager.shared.loadUserCart(forUser: userId) == nil {
                        CartManager.shared.updateCart(with: userCarts)
                        UserManager.shared.saveUserCart(CartManager.shared.getCart(), forUser: userId)
                    }
                    CartManager.shared.updateCartView()
                }
            case .failure(let error):
                print("Error fetching order history: \(error)")
            }
        }
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CartTableViewCell.nib(), forCellReuseIdentifier: CartTableViewCell.identifier)
        loadUserOrderHistory()
        
        if let user = user {
            nameLabel.text = "Имя: \(user.name.firstname.capitalized)"
            surnameLabel.text = "Фамилия: \(user.name.lastname.capitalized)"
            emailLabel.text = "Почта: \(user.email)"
            
            let selectedTheme = ThemeManager.shared.loadSelectedTheme(forUserId: user.id)
            themeControl.selectedSegmentIndex = selectedTheme
            themeChange()
        }
    }
    
    private func themeChange() {
        if let user = user {
            let selectedTheme = themeControl.selectedSegmentIndex
            ThemeManager.shared.saveSelectedTheme(selectedTheme, forUserId: user.id)
            ThemeManager.shared.applyTheme(selectedTheme)
        }
    }
    
    private func showChangePasswordAlert() {
        let alert = UIAlertController(title: "Изменение пароля", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Введите старый пароль"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { textField in
            textField.placeholder = "Введите новый пароль"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { textField in
            textField.placeholder = "Повторите новый пароль"
            textField.isSecureTextEntry = true
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let doneAction = UIAlertAction(title: "Готово", style: .default) { [weak self] _ in
            self?.handlePasswordChange(alert: alert)
        }
        doneAction.isEnabled = false

        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: OperationQueue.main) { _ in
            let oldPassword = alert.textFields?[0].text ?? ""
            let newPassword = alert.textFields?[1].text ?? ""
            let repeatPassword = alert.textFields?[2].text ?? ""
            doneAction.isEnabled = !oldPassword.isEmpty && !newPassword.isEmpty && !repeatPassword.isEmpty
        }

        alert.addAction(cancelAction)
        alert.addAction(doneAction)

        present(alert, animated: true, completion: nil)
    }
    
    private func handlePasswordChange(alert: UIAlertController) {
        guard let oldPassword = alert.textFields?[0].text,
              let newPassword = alert.textFields?[1].text,
              let repeatPassword = alert.textFields?[2].text else {
            return
        }

        if newPassword != repeatPassword {
            showAlert(message: "Новые пароли не совпадают")
            return
        }

        if oldPassword != user?.password {
            showAlert(message: "Неправильный пароль")
            return
        }
        
        user?.password = newPassword
        
        if let updatedUser = user {
            UserManager.shared.updateUser(updatedUser)
            showAlert(message: "Пароль успешно изменен")
        }
    }
    
    private func showDeleteProfileAlert() {
        let alert = UIAlertController(title: "Удаление профиля", message: "Вы уверены, что хотите удалить свой профиль?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteUserProfile()
        }

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)

        present(alert, animated: true, completion: nil)
    }

    private func deleteUserProfile() {
        if let currentUser = user {
            UserManager.shared.removeUser(currentUser)
            
            if let tabBarController = tabBarController as? TabBarController {
                tabBarController.updateTabBar(isLoggedIn: false)
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showLogOutAlert() {
        let alert = UIAlertController(title: "Выход из профиля", message: "Вы уверены, что хотите выйти из профиля?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let logOutAction = UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.performLogOut()
        }

        alert.addAction(cancelAction)
        alert.addAction(logOutAction)

        present(alert, animated: true, completion: nil)
    }
    
    private func performLogOut() {
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.updateTabBar(isLoggedIn: false)
        }
    }
    
    private func updateTableViewVisibility() {
        if userCarts.isEmpty {
            let label = UILabel()
            label.text = "Нет истории заказов"
            label.textColor = .gray
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.numberOfLines = 0
            tableView.backgroundView = label
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userCarts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell else {
            return UITableViewCell()
        }
        
        let cart = userCarts[indexPath.row]
        cell.configure(with: cart)
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
}
