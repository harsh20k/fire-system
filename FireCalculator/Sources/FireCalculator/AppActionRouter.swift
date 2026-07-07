import Foundation
import Observation
import SwiftUI

enum AppAction: String, CaseIterable, Identifiable {
    case checkpoints
    case history
    case exportPDF
    case shareData
    case importData
    case assistant
    case settings
    case closeSheet

    var id: String { rawValue }

    var title: String {
        switch self {
        case .checkpoints: "Checkpoints"
        case .history: "Change History"
        case .exportPDF: "Export PDF"
        case .shareData: "Share Data"
        case .importData: "Import Data"
        case .assistant: "FIRE Co-pilot"
        case .settings: "Settings"
        case .closeSheet: "Close"
        }
    }

    var systemImage: String {
        switch self {
        case .checkpoints: "clock.arrow.circlepath"
        case .history: "chart.xyaxis.line"
        case .exportPDF: "square.and.arrow.up"
        case .shareData: "arrow.up.doc"
        case .importData: "arrow.down.doc"
        case .assistant: "sparkles"
        case .settings: "gearshape"
        case .closeSheet: "xmark"
        }
    }
}

struct AppShortcut {
    let key: KeyEquivalent
    let modifiers: EventModifiers

    var displayString: String {
        ShortcutDisplay.format(key: key, modifiers: modifiers)
    }
}

enum AppShortcutRegistry {
    static func shortcut(for action: AppAction) -> AppShortcut? {
        switch action {
        case .checkpoints: AppShortcut(key: "c", modifiers: [])
        case .history: AppShortcut(key: "h", modifiers: [])
        case .exportPDF: AppShortcut(key: "e", modifiers: [])
        case .shareData: AppShortcut(key: "s", modifiers: [])
        case .importData: AppShortcut(key: "i", modifiers: [])
        case .assistant: AppShortcut(key: "j", modifiers: [])
        case .settings: AppShortcut(key: "k", modifiers: [])
        case .closeSheet: AppShortcut(key: .escape, modifiers: [])
        }
    }

    static var toolbarActions: [AppAction] {
        [.checkpoints, .history, .exportPDF, .shareData, .importData, .assistant, .settings]
    }
}

enum ShortcutDisplay {
    static func format(key: KeyEquivalent, modifiers: EventModifiers) -> String {
        guard !modifiers.isEmpty else {
            return symbol(for: key)
        }
        var parts: [String] = []
        if modifiers.contains(.control) { parts.append("⌃") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.command) { parts.append("⌘") }
        parts.append(symbol(for: key))
        return parts.joined()
    }

    private static func symbol(for key: KeyEquivalent) -> String {
        switch key.character {
        case ",": return ","
        case "\r", "\n": return "↩"
        case Character(UnicodeScalar(27)!): return "Esc"
        default:
            return String(key.character).uppercased()
        }
    }
}

@Observable
final class AppActionRouter {
    private(set) var pendingAction: AppAction?
    private(set) var actionTick = 0
    var pendingImportBundle: FirePlanBundle?
    var suppressShortcuts = false

    func perform(_ action: AppAction) {
        pendingAction = action
        actionTick += 1
    }

    func consumeAction() -> AppAction? {
        defer { pendingAction = nil }
        return pendingAction
    }
}
