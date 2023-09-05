import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let userManager = UserManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
        setupPasswordTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginTextField.text = ""
        passwordTextField.text = ""
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        loginProfile()
    }
    
    private func setupPasswordTextField() {
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        eyeButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        passwordTextField.rightViewMode = .always
        passwordTextField.rightView = eyeButton
    }
    
    private func loginProfile() {
        guard let username = loginTextField.text, let password = passwordTextField.text else { return }

        if let user = userManager.authenticateUser(username: username, password: password) {
            handleSuccessfulLogin(with: user)
        } else {
            showAlert(message: "Введены неправильные данные пользователя")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func handleSuccessfulLogin(with user: User) {
        userManager.currentUser = user
        
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.updateTabBar(isLoggedIn: true)
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()

        if let eyeButton = passwordTextField.rightView as? UIButton {
            let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
            eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            loginProfile()
        }
        return true
    }
}
