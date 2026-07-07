import SwiftUI

enum BrutalButtonVariant {
    case primary, secondary
}

struct BrutalButton: View {
    @Environment(\.colorScheme) private var scheme
    let title: String
    var variant: BrutalButtonVariant = .primary
    var disabled: Bool = false
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            BrutalText(
                text: title,
                variant: .body,
                bold: true,
                color: foreground,
                uppercase: true,
                tracking: 0.8
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(background)
            .brutalistBorder(pressed: pressed)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeOut(duration: 0.08)) { pressed = pressing }
        }, perform: {})
    }

    private var background: Color {
        switch variant {
        case .primary: Theme.primary
        case .secondary: Theme.surface(scheme)
        }
    }

    private var foreground: Color {
        switch variant {
        case .primary: .white
        case .secondary: Theme.ink(scheme)
        }
    }
}
