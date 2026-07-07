import SwiftUI

struct FireCalculatorCommands: Commands {
    @Bindable var router: AppActionRouter

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Command Palette…") { router.perform(.commandPalette) }
                .keyboardShortcut("k", modifiers: .command)
        }

        CommandMenu("Plan") {
            Button("Checkpoints…") { router.perform(.checkpoints) }
                .keyboardShortcut("c", modifiers: [.command, .shift])
            Button("Change History…") { router.perform(.history) }
                .keyboardShortcut("h", modifiers: [.command, .shift])
            Divider()
            Button("Export PDF…") { router.perform(.exportPDF) }
                .keyboardShortcut("e", modifiers: .command)
            Button("Share Data…") { router.perform(.shareData) }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            Button("Import Data…") { router.perform(.importData) }
                .keyboardShortcut("i", modifiers: [.command, .shift])
        }

        CommandGroup(after: .appSettings) {
            Button("FIRE Co-pilot") { router.perform(.assistant) }
                .keyboardShortcut("j", modifiers: .command)
        }
    }
}
