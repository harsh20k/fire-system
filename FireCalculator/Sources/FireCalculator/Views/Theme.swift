import SwiftUI

/// Neo-brutalist design tokens — airy spacing, bold borders, orange-red accents.
enum Theme {
    static let borderWidth: CGFloat = 2.5
    static let shadowOffset: CGFloat = 4
    static let cornerRadius: CGFloat = 2

    enum Spacing {
        static let screen: CGFloat = 32
        static let section: CGFloat = 40
        static let card: CGFloat = 28
        static let inline: CGFloat = 16
    }

    // Juicy orange-red primary
    static let primary = Color(red: 0.96, green: 0.35, blue: 0.22)       // #F55A38
    static let primaryDeep = Color(red: 0.91, green: 0.22, blue: 0.18)   // #E8382E
    static let accent = Color(red: 0.863, green: 0.149, blue: 0.149)
    static let inkDark = Color(red: 0.067, green: 0.067, blue: 0.067)
    static let shadow = Color.black.opacity(0.30)

    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.45, blue: 0.26),
                Color(red: 0.91, green: 0.22, blue: 0.18),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static let pine = primary
    static let ochre = Color(red: 0.851, green: 0.467, blue: 0.024)
    static let slate = Color(red: 0.145, green: 0.388, blue: 0.922)
    static let brick = accent

    static let sidebarWidth: CGFloat = 240

    static func neutral(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.110, green: 0.110, blue: 0.118)
            : Color(red: 0.961, green: 0.961, blue: 0.941)
    }

    static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.165, green: 0.165, blue: 0.173)
            : .white
    }

    static func mutedText(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.580, green: 0.580, blue: 0.600)
            : Color(red: 0.420, green: 0.447, blue: 0.502)
    }

    static func border(_ scheme: ColorScheme) -> Color { inkDark }

    static func paper(_ scheme: ColorScheme) -> Color { neutral(scheme) }
    static func card(_ scheme: ColorScheme) -> Color { surface(scheme) }
    static func ink(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.961, green: 0.961, blue: 0.941) : inkDark
    }
    static func hairline(_ scheme: ColorScheme) -> Color { border(scheme) }

    enum Typography {
        static let title = Font.system(size: 28, weight: .bold)
        static let body = Font.system(size: 17, weight: .regular)
        static let caption = Font.system(size: 13, weight: .regular)
        static let hero = Font.system(size: 32, weight: .heavy)
        static let sectionLabel = Font.system(size: 13, weight: .bold)
    }

    static let mono = Typography.sectionLabel
    static let monoSmall = Typography.caption
}

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

    func primaryGradientBackground() -> some View {
        background(Theme.primaryGradient)
    }
}
