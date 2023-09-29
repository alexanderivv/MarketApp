import UIKit
import PassKit

class CartViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var payWithApplePayButtonLabel: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction func payWithApplePayButton(_ sender: Any) {
        payWithApplePay()
    }

    @IBAction func removeAllButton(_ sender: Any) {
        removeAll()
    }

    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProductTableViewCell.nib(), forCellReuseIdentifier: ProductTableViewCell.identifier)

        NotificationCenter.default.addObserver(self, selector: #selector(cartUpdated), name: NSNotification.Name("CartUpdatedNotification"), object: nil)

        updateUI()
    }

    private func updateUI() {
        let cartItems = CartManager.shared.getCartItems()

        if cartItems.isEmpty {
            tableView?.backgroundView = createEmptyCartLabel()
            tableView?.separatorStyle = .none
            payWithApplePayButtonLabel.isEnabled = false
        } else {
            tableView?.backgroundView = nil
            tableView?.separatorStyle = .singleLine
            payWithApplePayButtonLabel.isEnabled = true
        }

        tableView?.reloadData()
        totalPriceLabel?.text = "Общая сумма: \(FormatterManager.shared.formattedPrice(for: CartManager.shared.totalCartPrice()))$"

        NotificationCenter.default.post(name: NSNotification.Name("CartItemUpdatedNotification"), object: nil)
    }

    private func createEmptyCartLabel() -> UILabel {
        let label = UILabel()
        label.text = "Нет товаров в корзине"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }

    private func removeAll() {
        let cartItems = CartManager.shared.getCartItems()

        if cartItems.isEmpty {
            let emptyCartAlert = UIAlertController(title: "Корзина пустая", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            emptyCartAlert.addAction(okAction)
            present(emptyCartAlert, animated: true, completion: nil)
        } else {
            let removeAllAlert = UIAlertController(title: "Удалить все товары?", message: "Вы уверены, что хотите удалить все товары из корзины?", preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                CartManager.shared.clearCart()
                if let user = UserManager.shared.currentUser {
                    UserManager.shared.saveUserCart(CartManager.shared.getCart(), forUser: user.id)
                }

                self?.updateUI()
            }

            removeAllAlert.addAction(cancelAction)
            removeAllAlert.addAction(confirmAction)

            present(removeAllAlert, animated: true, completion: nil)
        }
    }

    private func payWithApplePay() {
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard], capabilities: .capability3DS) {
            let request = PKPaymentRequest()
            request.merchantIdentifier = "merchant.identifier"
            request.countryCode = "US"
            request.currencyCode = "USD"
            request.supportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard]
            request.merchantCapabilities = .capability3DS
            request.paymentSummaryItems = [
                PKPaymentSummaryItem(label: "Fake Store", amount: NSDecimalNumber(decimal: CartManager.shared.totalCartPrice()))
            ]

            let paymentController = PKPaymentAuthorizationViewController(paymentRequest: request)
            paymentController?.delegate = self
            present(paymentController!, animated: true, completion: nil)
        } else {
            return
        }
    }

    @objc private func cartUpdated() {
        updateUI()
    }
}

extension CartViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CartManager.shared.getCartItems().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as! ProductTableViewCell
        let product = CartManager.shared.getCartItems()[indexPath.row]
        cell.configure(with: product)
        return cell
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, completionHandler) in
            let product = CartManager.shared.getCartItems()[indexPath.row]
            CartManager.shared.removeFromCart(product)

            NotificationCenter.default.post(name: NSNotification.Name("CartItemUpdatedNotification"), object: nil)

            if let user = UserManager.shared.currentUser {
                UserManager.shared.saveUserCart(CartManager.shared.getCart(), forUser: user.id)
            }

            tableView.deleteRows(at: [indexPath], with: .fade)
            self?.updateUI()
            completionHandler(true)
        }

        let cartIcon = UIImage(systemName: "trash.fill")
        deleteAction.image = cartIcon
        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}

extension CartViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        completion(.failure)
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        if controller.responds(to: #selector(paymentAuthorizationViewController(_:didAuthorizePayment:completion:))) {
            controller.dismiss(animated: true, completion: nil)
        } else {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
