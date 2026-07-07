import SwiftUI

struct FireCalculatorCommands: Commands {
    @Bindable var router: AppActionRouter

    var body: some Commands {
        CommandMenu("Plan") {
            planButton("Checkpoints…", action: .checkpoints, key: "c")
            planButton("Change History…", action: .history, key: "h")
            Divider()
            planButton("Export PDF…", action: .exportPDF, key: "e")
            planButton("Share Data…", action: .shareData, key: "s")
            planButton("Import Data…", action: .importData, key: "i")
        }

        CommandGroup(after: .appSettings) {
            planButton("FIRE Co-pilot", action: .assistant, key: "j")
            planButton("Settings…", action: .settings, key: "k")
        }
    }

    @ViewBuilder
    private func planButton(_ title: String, action: AppAction, key: KeyEquivalent) -> some View {
        Button(title) { router.perform(action) }
            .modifier(ConditionalKeyboardShortcut(key: key, modifiers: [], enabled: !router.suppressShortcuts))
    }
}

struct ConditionalKeyboardShortcut: ViewModifier {
    let key: KeyEquivalent
    let modifiers: EventModifiers
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.keyboardShortcut(key, modifiers: modifiers)
        } else {
            content
        }
    }
}
