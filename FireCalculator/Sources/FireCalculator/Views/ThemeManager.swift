import SwiftUI

enum LightThemePreset: String, CaseIterable, Identifiable, Codable {
    case parchment
    case mist
    case sand

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .parchment: "Parchment"
        case .mist: "Mist"
        case .sand: "Sand"
        }
    }
}

enum DarkThemePreset: String, CaseIterable, Identifiable, Codable {
    case forest
    case slate
    case ember

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .forest: "Forest"
        case .slate: "Slate"
        case .ember: "Ember"
        }
    }
}

struct ThemePalette {
    let paper: Color
    let card: Color
    let ink: Color
    let mutedText: Color
    let hairline: Color
    let pine: Color
    let ochre: Color
    let slate: Color
    let brick: Color
}

@Observable
final class ThemeManager {
    private enum Keys {
        static let light = "lightThemePreset"
        static let dark = "darkThemePreset"
    }

    var lightPreset: LightThemePreset {
        didSet { UserDefaults.standard.set(lightPreset.rawValue, forKey: Keys.light) }
    }

    var darkPreset: DarkThemePreset {
        didSet { UserDefaults.standard.set(darkPreset.rawValue, forKey: Keys.dark) }
    }

    var appearanceID: String { "\(lightPreset.rawValue)-\(darkPreset.rawValue)" }

    init() {
        let defaults = UserDefaults.standard
        let lightRaw = defaults.string(forKey: Keys.light) ?? LightThemePreset.parchment.rawValue
        let darkRaw = defaults.string(forKey: Keys.dark) ?? DarkThemePreset.forest.rawValue
        lightPreset = LightThemePreset(rawValue: lightRaw) ?? .parchment
        darkPreset = DarkThemePreset(rawValue: darkRaw) ?? .forest
    }
}
