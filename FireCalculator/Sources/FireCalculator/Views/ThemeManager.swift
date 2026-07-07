import SwiftUI

/// Brutalist light/dark appearance preference.
@Observable
final class ThemeManager {
    private static let prefersLightKey = "prefersLightAppearance"

    var prefersLight: Bool {
        didSet { UserDefaults.standard.set(prefersLight, forKey: Self.prefersLightKey) }
    }

    var appearanceID: String { prefersLight ? "light" : "dark" }

    var colorScheme: ColorScheme? { prefersLight ? .light : .dark }

    init() {
        if UserDefaults.standard.object(forKey: Self.prefersLightKey) != nil {
            prefersLight = UserDefaults.standard.bool(forKey: Self.prefersLightKey)
        } else {
            prefersLight = true
        }
    }
}
