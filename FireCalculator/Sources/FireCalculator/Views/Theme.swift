import SwiftUI

/// A muted, "paper" inspired palette — warm off-white parchment in light mode,
/// deep charcoal paper in dark mode — layered under native Liquid Glass materials.
enum Theme {
    private enum Keys {
        static let light = "lightThemePreset"
        static let dark = "darkThemePreset"
    }

    static func currentLightPreset() -> LightThemePreset {
        let raw = UserDefaults.standard.string(forKey: Keys.light) ?? LightThemePreset.parchment.rawValue
        return LightThemePreset(rawValue: raw) ?? .parchment
    }

    static func currentDarkPreset() -> DarkThemePreset {
        let raw = UserDefaults.standard.string(forKey: Keys.dark) ?? DarkThemePreset.forest.rawValue
        return DarkThemePreset(rawValue: raw) ?? .forest
    }

    // Shared accent anchors (used as defaults in presets)
    static let pine = Color(red: 0.184, green: 0.365, blue: 0.306)
    static let ochre = Color(red: 0.788, green: 0.518, blue: 0.247)
    static let slate = Color(red: 0.247, green: 0.431, blue: 0.659)
    static let brick = Color(red: 0.659, green: 0.263, blue: 0.247)

    static func paper(_ scheme: ColorScheme) -> Color { palette(for: scheme).paper }
    static func card(_ scheme: ColorScheme) -> Color { palette(for: scheme).card }
    static func ink(_ scheme: ColorScheme) -> Color { palette(for: scheme).ink }
    static func mutedText(_ scheme: ColorScheme) -> Color { palette(for: scheme).mutedText }
    static func hairline(_ scheme: ColorScheme) -> Color { palette(for: scheme).hairline }

    static func palette(for scheme: ColorScheme) -> ThemePalette {
        scheme == .dark ? palette(for: currentDarkPreset()) : palette(for: currentLightPreset())
    }

    static func palette(for preset: LightThemePreset) -> ThemePalette {
        switch preset {
        case .parchment:
            ThemePalette(
                paper: Color(red: 0.949, green: 0.941, blue: 0.910),
                card: Color(red: 0.984, green: 0.980, blue: 0.961),
                ink: Color(red: 0.110, green: 0.169, blue: 0.135),
                mutedText: Color(red: 0.357, green: 0.420, blue: 0.376),
                hairline: Color(red: 0.878, green: 0.863, blue: 0.796),
                pine: pine, ochre: ochre, slate: slate, brick: brick
            )
        case .mist:
            ThemePalette(
                paper: Color(red: 0.933, green: 0.945, blue: 0.957),
                card: Color(red: 0.973, green: 0.980, blue: 0.988),
                ink: Color(red: 0.102, green: 0.137, blue: 0.196),
                mutedText: Color(red: 0.353, green: 0.396, blue: 0.439),
                hairline: Color(red: 0.831, green: 0.863, blue: 0.894),
                pine: Color(red: 0.165, green: 0.380, blue: 0.345),
                ochre: Color(red: 0.737, green: 0.502, blue: 0.282),
                slate: Color(red: 0.220, green: 0.447, blue: 0.690),
                brick: Color(red: 0.620, green: 0.290, blue: 0.275)
            )
        case .sand:
            ThemePalette(
                paper: Color(red: 0.961, green: 0.941, blue: 0.902),
                card: Color(red: 0.980, green: 0.969, blue: 0.941),
                ink: Color(red: 0.239, green: 0.180, blue: 0.122),
                mutedText: Color(red: 0.478, green: 0.420, blue: 0.345),
                hairline: Color(red: 0.910, green: 0.875, blue: 0.816),
                pine: Color(red: 0.204, green: 0.392, blue: 0.318),
                ochre: Color(red: 0.808, green: 0.545, blue: 0.275),
                slate: Color(red: 0.275, green: 0.416, blue: 0.588),
                brick: Color(red: 0.690, green: 0.310, blue: 0.255)
            )
        }
    }

    static func palette(for preset: DarkThemePreset) -> ThemePalette {
        switch preset {
        case .forest:
            ThemePalette(
                paper: Color(red: 0.114, green: 0.129, blue: 0.114),
                card: Color(red: 0.145, green: 0.161, blue: 0.145),
                ink: Color(red: 0.925, green: 0.933, blue: 0.910),
                mutedText: Color(red: 0.667, green: 0.694, blue: 0.655),
                hairline: Color(red: 0.267, green: 0.290, blue: 0.259),
                pine: pine, ochre: ochre, slate: slate, brick: brick
            )
        case .slate:
            ThemePalette(
                paper: Color(red: 0.102, green: 0.122, blue: 0.149),
                card: Color(red: 0.133, green: 0.157, blue: 0.188),
                ink: Color(red: 0.910, green: 0.925, blue: 0.941),
                mutedText: Color(red: 0.541, green: 0.576, blue: 0.620),
                hairline: Color(red: 0.227, green: 0.259, blue: 0.302),
                pine: Color(red: 0.200, green: 0.420, blue: 0.380),
                ochre: Color(red: 0.769, green: 0.537, blue: 0.310),
                slate: Color(red: 0.290, green: 0.478, blue: 0.710),
                brick: Color(red: 0.690, green: 0.325, blue: 0.310)
            )
        case .ember:
            ThemePalette(
                paper: Color(red: 0.122, green: 0.102, blue: 0.090),
                card: Color(red: 0.165, green: 0.141, blue: 0.125),
                ink: Color(red: 0.941, green: 0.922, blue: 0.902),
                mutedText: Color(red: 0.659, green: 0.596, blue: 0.533),
                hairline: Color(red: 0.271, green: 0.239, blue: 0.220),
                pine: Color(red: 0.220, green: 0.420, blue: 0.345),
                ochre: Color(red: 0.820, green: 0.561, blue: 0.310),
                slate: Color(red: 0.361, green: 0.478, blue: 0.588),
                brick: Color(red: 0.749, green: 0.361, blue: 0.286)
            )
        }
    }

    static let mono = Font.system(.caption, design: .monospaced)
    static let monoSmall = Font.system(size: 10, weight: .medium, design: .monospaced)
    static let serifTitle = Font.system(.largeTitle, design: .serif).weight(.bold)
    static let serifBody = Font.system(.body, design: .serif)
}

/// Reusable Liquid Glass card container matching the "paper" aesthetic.
struct GlassPaperCard<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    var accent: Color = Theme.pine
    var padding: CGFloat = 22
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Theme.card(scheme).opacity(0.5))
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Theme.hairline(scheme), lineWidth: 1)
            }
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accent)
                    .frame(width: 4)
                    .padding(.vertical, 10)
            }
    }
}

struct ThemePresetSwatch: View {
    let paper: Color
    let accent: Color
    var selected: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(paper).frame(width: 16, height: 16)
            Circle().fill(accent).frame(width: 10, height: 10)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(selected ? Theme.pine : Color.clear, lineWidth: 1.5)
        )
    }
}
