import SwiftUI

struct ShortcutBadge: View {
    @Environment(\.colorScheme) private var scheme
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(Theme.mutedText(scheme))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Theme.neutral(scheme))
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(Theme.border(scheme).opacity(0.35), lineWidth: 1)
            }
    }
}

struct ShortcutToolbarButton: View {
    let title: String
    let systemImage: String
    let shortcut: AppShortcut?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                if let shortcut {
                    ShortcutBadge(text: shortcut.displayString)
                }
            }
            .help(title + (shortcut.map { " (\($0.displayString))" } ?? ""))
        }
        .applyShortcut(shortcut)
    }
}

struct ShortcutLabeledButton: View {
    let title: String
    let shortcut: AppShortcut?
    let variant: BrutalButtonVariant
    let action: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            BrutalButton(title: title, variant: variant, action: action)
            if let shortcut {
                ShortcutBadge(text: shortcut.displayString)
            }
        }
        .applyShortcut(shortcut, action: action)
    }
}

private extension View {
    @ViewBuilder
    func applyShortcut(_ shortcut: AppShortcut?, action: (() -> Void)? = nil) -> some View {
        if let shortcut {
            self.keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
        } else {
            self
        }
    }
}
