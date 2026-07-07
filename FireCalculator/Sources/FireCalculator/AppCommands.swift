import SwiftUI

struct FireCalculatorCommands: Commands {
    @Bindable var router: AppActionRouter

    var body: some Commands {
        CommandMenu("Plan") {
            Button("Checkpoints…") { router.perform(.checkpoints) }
                .keyboardShortcut("c", modifiers: [])
            Button("Change History…") { router.perform(.history) }
                .keyboardShortcut("h", modifiers: [])
            Divider()
            Button("Export PDF…") { router.perform(.exportPDF) }
                .keyboardShortcut("e", modifiers: [])
            Button("Share Data…") { router.perform(.shareData) }
                .keyboardShortcut("s", modifiers: [])
            Button("Import Data…") { router.perform(.importData) }
                .keyboardShortcut("i", modifiers: [])
        }

        CommandGroup(after: .appSettings) {
            Button("FIRE Co-pilot") { router.perform(.assistant) }
                .keyboardShortcut("j", modifiers: [])
            Button("Settings…") { router.perform(.settings) }
                .keyboardShortcut("k", modifiers: [])
        }
    }
}
