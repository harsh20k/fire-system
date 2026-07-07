import SwiftUI

/// Neo-brutalist design tokens — airy spacing, bold borders, flat colors.
enum Theme {
    // MARK: - Structural constants

    static let borderWidth: CGFloat = 2.5
    static let shadowOffset: CGFloat = 4
    static let cornerRadius: CGFloat = 2

    // MARK: - Spacing

    enum Spacing {
        static let screen: CGFloat = 32
        static let section: CGFloat = 40
        static let card: CGFloat = 28
        static let inline: CGFloat = 16
    }

    // MARK: - Semantic colors (fixed anchors)

    static let primary = Color(red: 0.086, green: 0.639, blue: 0.290)   // #16A34A
    static let accent = Color(red: 0.863, green: 0.149, blue: 0.149)    // #DC2626
    static let inkDark = Color(red: 0.067, green: 0.067, blue: 0.067)   // #111111
    static let shadow = Color(red: 0.067, green: 0.067, blue: 0.067)

    // Section accent aliases (backward-compatible)
    static let pine = primary
    static let ochre = Color(red: 0.851, green: 0.467, blue: 0.024)     // #D97706 amber
    static let slate = Color(red: 0.145, green: 0.388, blue: 0.922)     // #2563EB blue
    static let brick = accent

    // MARK: - Scheme-aware palette

    static func neutral(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.110, green: 0.110, blue: 0.118)
            : Color(red: 0.961, green: 0.961, blue: 0.941)              // #F5F5F0
    }

    static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.165, green: 0.165, blue: 0.173)
            : .white
    }

    static func mutedText(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.580, green: 0.580, blue: 0.600)
            : Color(red: 0.420, green: 0.447, blue: 0.502)              // #6B7280
    }

    static func border(_ scheme: ColorScheme) -> Color { inkDark }

    // Legacy aliases
    static func paper(_ scheme: ColorScheme) -> Color { neutral(scheme) }
    static func card(_ scheme: ColorScheme) -> Color { surface(scheme) }
    static func ink(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.961, green: 0.961, blue: 0.941) : inkDark
    }
    static func hairline(_ scheme: ColorScheme) -> Color { border(scheme) }

    // MARK: - Typography (exactly three sizes)

    enum Typography {
        static let title = Font.system(size: 28, weight: .bold)
        static let body = Font.system(size: 17, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
        static let hero = Font.system(size: 36, weight: .heavy)
        static let sectionLabel = Font.system(size: 13, weight: .bold)
    }

    // Legacy font aliases (map to new scale)
    static let mono = Typography.sectionLabel
    static let monoSmall = Typography.caption
}

// MARK: - Brutalist card modifier

struct BrutalistBorder: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var pressed: Bool = false

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .strokeBorder(Theme.border(scheme), lineWidth: Theme.borderWidth)
            }
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(Theme.shadow)
                    .offset(
                        x: pressed ? 0 : Theme.shadowOffset,
                        y: pressed ? 0 : Theme.shadowOffset
                    )
            )
            .offset(
                x: pressed ? Theme.shadowOffset : 0,
                y: pressed ? Theme.shadowOffset : 0
            )
    }
}

extension View {
    func brutalistBorder(pressed: Bool = false) -> some View {
        modifier(BrutalistBorder(pressed: pressed))
    }
}
