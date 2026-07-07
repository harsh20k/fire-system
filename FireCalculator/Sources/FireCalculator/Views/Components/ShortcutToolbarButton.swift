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
    @Environment(AppActionRouter.self) private var router
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
        .applyShortcut(shortcut, enabled: !router.suppressShortcuts)
    }
}

struct ShortcutLabeledButton: View {
    @Environment(AppActionRouter.self) private var router
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
        .applyShortcut(shortcut, enabled: !router.suppressShortcuts, action: action)
    }
}

private extension View {
    @ViewBuilder
    func applyShortcut(_ shortcut: AppShortcut?, enabled: Bool = true, action: (() -> Void)? = nil) -> some View {
        if let shortcut {
            modifier(ConditionalKeyboardShortcut(key: shortcut.key, modifiers: shortcut.modifiers, enabled: enabled))
        } else {
            self
        }
    }
}
