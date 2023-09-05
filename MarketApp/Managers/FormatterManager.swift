import UIKit

class FormatterManager {
    static let shared = FormatterManager()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    private let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter
    }()
    
    func formattedPrice(for price: Decimal) -> String {
        if let formattedPrice = numberFormatter.string(from: NSDecimalNumber(decimal: price)) {
            return formattedPrice
        } else {
            return "\(price)"
        }
    }
    
    func convertDateString(_ dateString: String) -> String {
        if let date = inputDateFormatter.date(from: dateString) {
            return outputDateFormatter.string(from: date)
        } else {
            return ""
        }
    }
}
