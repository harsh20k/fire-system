import SwiftUI

enum BrutalTextVariant {
    case title, body, caption, hero, sectionLabel
}

struct BrutalText: View {
    @Environment(\.colorScheme) private var scheme
    let text: String
    var variant: BrutalTextVariant = .body
    var bold: Bool = false
    var color: Color? = nil
    var uppercase: Bool = false
    var tracking: CGFloat = 0

    var body: some View {
        Text(uppercase ? text.uppercased() : text)
            .font(font)
            .fontWeight(bold ? .bold : nil)
            .tracking(tracking)
            .foregroundStyle(color ?? Theme.ink(scheme))
    }

    private var font: Font {
        switch variant {
        case .title: Theme.Typography.title
        case .body: Theme.Typography.body
        case .caption: Theme.Typography.caption
        case .hero: Theme.Typography.hero
        case .sectionLabel: Theme.Typography.sectionLabel
        }
    }
}
