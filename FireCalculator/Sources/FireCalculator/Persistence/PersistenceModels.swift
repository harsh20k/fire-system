import Foundation
import SwiftData

/// The single "live" working scenario. There is exactly one row of this in the store;
/// it holds the current slider state so it persists across app launches.
@Model
final class ScenarioState {
    var updatedAt: Date
    var inputsJSON: Data

    init(inputs: FireInputs = .default) {
        self.updatedAt = .now
        self.inputsJSON = (try? JSONEncoder().encode(inputs)) ?? Data()
    }

    var inputs: FireInputs {
        get { (try? JSONDecoder().decode(FireInputs.self, from: inputsJSON)) ?? .default }
        set {
            inputsJSON = (try? JSONEncoder().encode(newValue)) ?? inputsJSON
            updatedAt = .now
        }
    }
}

/// A named, revertable snapshot of the sliders — "source control" for the scenario.
@Model
final class Checkpoint {
    var id: UUID
    var name: String
    var note: String
    var createdAt: Date
    var inputsJSON: Data

    init(name: String, note: String = "", inputs: FireInputs) {
        self.id = UUID()
        self.name = name
        self.note = note
        self.createdAt = .now
        self.inputsJSON = (try? JSONEncoder().encode(inputs)) ?? Data()
    }

    init(id: UUID, name: String, note: String, createdAt: Date, inputs: FireInputs) {
        self.id = id
        self.name = name
        self.note = note
        self.createdAt = createdAt
        self.inputsJSON = (try? JSONEncoder().encode(inputs)) ?? Data()
    }

    var inputs: FireInputs {
        (try? JSONDecoder().decode(FireInputs.self, from: inputsJSON)) ?? .default
    }
}

/// One logged change to a single field, for the long-term change-tracking / history feature.
@Model
final class ChangeEvent {
    var id: UUID
    var timestamp: Date
    var fieldKey: String
    var oldValue: Double
    var newValue: Double
    /// "user" or "assistant" — who made the change.
    var source: String

    init(fieldKey: String, oldValue: Double, newValue: Double, source: String = "user") {
        self.id = UUID()
        self.timestamp = .now
        self.fieldKey = fieldKey
        self.oldValue = oldValue
        self.newValue = newValue
        self.source = source
    }

    init(id: UUID, timestamp: Date, fieldKey: String, oldValue: Double, newValue: Double, source: String) {
        self.id = id
        self.timestamp = timestamp
        self.fieldKey = fieldKey
        self.oldValue = oldValue
        self.newValue = newValue
        self.source = source
    }
}

/// A single chat turn with the Gemini assistant, persisted so the conversation survives relaunches.
@Model
final class AssistantMessage {
    var id: UUID
    var timestamp: Date
    var role: String // "user" | "model" | "system"
    var text: String

    init(role: String, text: String) {
        self.id = UUID()
        self.timestamp = .now
        self.role = role
        self.text = text
    }

    init(id: UUID, timestamp: Date, role: String, text: String) {
        self.id = id
        self.timestamp = timestamp
        self.role = role
        self.text = text
    }
}
