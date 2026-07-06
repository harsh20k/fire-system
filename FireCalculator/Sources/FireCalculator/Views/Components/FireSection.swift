import SwiftUI

/// Collapsible glass-card section, mirroring the original prototype's numbered sections
/// (Target, Home, Household & Income, Expenses).
struct FireSection<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    let number: String
    let title: String
    let accent: Color
    var summary: String? = nil
    @State private var open: Bool = true
    @State private var headerHovered = false
    @ViewBuilder var content: Content

    var body: some View {
        GlassPaperCard(accent: accent, padding: 20) {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { open.toggle() }
                } label: {
                    HStack(spacing: 10) {
                        Text("\(number) — \(title)")
                            .font(Theme.mono)
                            .foregroundStyle(accent)
                            .textCase(.uppercase)
                            .tracking(1.2)
                        Spacer(minLength: 8)
                        if !open, let summary {
                            Text(summary)
                                .font(Theme.mono)
                                .foregroundStyle(Theme.mutedText(scheme))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(accent)
                            .rotationEffect(.degrees(open ? 0 : -90))
                            .frame(width: 16, height: 16)
                    }
                    .contentShape(Rectangle())
                    .padding(.vertical, 8)
                    .padding(.horizontal, -8)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(accent.opacity(headerHovered ? 0.08 : 0))
                    )
                }
                .buttonStyle(.plain)
                .onHover { headerHovered = $0 }

                if open {
                    VStack(alignment: .leading, spacing: 0) {
                        content
                    }
                    .padding(.top, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .id("fire-section-\(number)")
    }
}

struct FireSubHead: View {
    let label: String
    let accent: Color

    var body: some View {
        Text(label)
            .font(Theme.monoSmall)
            .textCase(.uppercase)
            .tracking(1)
            .foregroundStyle(accent)
            .padding(.leading, 10)
            .overlay(alignment: .leading) {
                Rectangle().fill(accent).frame(width: 2)
            }
            .padding(.vertical, 12)
    }
}
