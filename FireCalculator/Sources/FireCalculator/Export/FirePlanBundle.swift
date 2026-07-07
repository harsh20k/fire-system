import Foundation

enum ImportMode: String, CaseIterable {
    case replace
    case merge
}

struct CheckpointDTO: Codable, Identifiable {
    var id: UUID
    var name: String
    var note: String
    var createdAt: Date
    var inputs: FireInputs

    init(from checkpoint: Checkpoint) {
        id = checkpoint.id
        name = checkpoint.name
        note = checkpoint.note
        createdAt = checkpoint.createdAt
        inputs = checkpoint.inputs
    }
}

struct ChangeEventDTO: Codable, Identifiable {
    var id: UUID
    var timestamp: Date
    var fieldKey: String
    var oldValue: Double
    var newValue: Double
    var source: String

    init(from event: ChangeEvent) {
        id = event.id
        timestamp = event.timestamp
        fieldKey = event.fieldKey
        oldValue = event.oldValue
        newValue = event.newValue
        source = event.source
    }
}

struct AssistantMessageDTO: Codable, Identifiable {
    var id: UUID
    var timestamp: Date
    var role: String
    var text: String

    init(from message: AssistantMessage) {
        id = message.id
        timestamp = message.timestamp
        role = message.role
        text = message.text
    }
}

/// Portable export of the full FIRE plan — sliders, checkpoints, history, and chat.
struct FirePlanBundle: Codable {
    static let currentVersion = 1

    var formatVersion: Int
    var exportedAt: Date
    var exportedBy: String
    var scenario: FireInputs
    var checkpoints: [CheckpointDTO]
    var changeEvents: [ChangeEventDTO]
    var assistantMessages: [AssistantMessageDTO]

    init(
        scenario: FireInputs,
        checkpoints: [Checkpoint],
        changeEvents: [ChangeEvent],
        assistantMessages: [AssistantMessage],
        exportedBy: String = Personalization.coupleNames
    ) {
        formatVersion = Self.currentVersion
        exportedAt = .now
        self.exportedBy = exportedBy
        self.scenario = scenario
        self.checkpoints = checkpoints.map(CheckpointDTO.init)
        self.changeEvents = changeEvents.map(ChangeEventDTO.init)
        self.assistantMessages = assistantMessages.map(AssistantMessageDTO.init)
    }

    var isSupported: Bool {
        formatVersion <= Self.currentVersion
    }
}

enum FirePlanBundleError: LocalizedError {
    case unsupportedVersion(Int)
    case decodeFailed
    case emptyScenario

    var errorDescription: String? {
        switch self {
        case .unsupportedVersion(let v):
            "This file was made with a newer app version (format \(v)). Please update Fire Calculator."
        case .decodeFailed:
            "Couldn't read plan file. The file may be corrupt or not a valid .fireplan export."
        case .emptyScenario:
            "The plan file had no slider data. Loaded defaults instead."
        }
    }
}
