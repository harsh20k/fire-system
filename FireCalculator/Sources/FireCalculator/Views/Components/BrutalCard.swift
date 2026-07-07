import SwiftUI

struct BrutalCard<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    var accent: Color? = nil
    var padding: CGFloat = Theme.Spacing.card
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Theme.surface(scheme))
            .brutalistBorder()
            .overlay(alignment: .leading) {
                if let accent {
                    Rectangle()
                        .fill(accent)
                        .frame(width: 4)
                        .padding(.vertical, 8)
                }
            }
    }
}

struct BrutalScreen<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    var padding: CGFloat = Theme.Spacing.screen
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.neutral(scheme))
    }
}
