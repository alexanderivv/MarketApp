import UIKit

class ThemeManager {
    static let shared = ThemeManager()

    private init() {}

    private let themeKeyPrefix = "SelectedThemeForUser"

    func saveSelectedTheme(_ theme: Int, forUserId userId: Int) {
        UserDefaults.standard.set(theme, forKey: "\(themeKeyPrefix)_\(userId)")
    }

    func loadSelectedTheme(forUserId userId: Int) -> Int {
        return UserDefaults.standard.integer(forKey: "\(themeKeyPrefix)_\(userId)")
    }
    
    func applyTheme(_ themeIndex: Int) {
            let theme: UIUserInterfaceStyle

            switch themeIndex {
            case 0:
                theme = .unspecified
            case 1:
                theme = .light
            case 2:
                theme = .dark
            default:
                return
            }

            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = theme
            }
        }
    }
}
