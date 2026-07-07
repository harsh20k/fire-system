import Foundation
import SwiftData
import Observation
import SwiftUI

/// Central observable store: owns the live `FireInputs`, derived `FireResults`,
/// and mediates all persistence (scenario autosave, checkpoints, change history).
@Observable
final class AppStore {
    var inputs: FireInputs {
        didSet { recompute() }
    }
    private(set) var results: FireResults = .init()

    var modelContext: ModelContext?

    init(inputs: FireInputs = .default) {
        self.inputs = inputs
        recompute()
    }

    func attach(context: ModelContext) {
        self.modelContext = context
        loadOrCreateScenario()
    }

    private func recompute() {
        results = FireCalculationEngine.compute(inputs: inputs)
    }

    // MARK: - Scenario autosave

    private func loadOrCreateScenario() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<ScenarioState>()
        if let existing = try? context.fetch(descriptor).first {
            inputs = existing.inputs
        } else {
            let state = ScenarioState(inputs: inputs)
            context.insert(state)
            try? context.save()
        }
    }

    func persistScenario() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<ScenarioState>()
        if let existing = try? context.fetch(descriptor).first {
            existing.inputs = inputs
        } else {
            context.insert(ScenarioState(inputs: inputs))
        }
        try? context.save()
    }

    // MARK: - Change tracking

    /// Call when a slider commits (drag ended) to log a `ChangeEvent` and autosave.
    func commitChange(field: String, from oldValue: Double, to newValue: Double, source: String = "user") {
        guard oldValue != newValue else { return }
        guard let context = modelContext else { return }
        context.insert(ChangeEvent(fieldKey: field, oldValue: oldValue, newValue: newValue, source: source))
        try? context.save()
        persistScenario()
    }

    func recentChanges(limit: Int = 50) -> [ChangeEvent] {
        guard let context = modelContext else { return [] }
        var descriptor = FetchDescriptor<ChangeEvent>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        descriptor.fetchLimit = limit
        return (try? context.fetch(descriptor)) ?? []
    }

    func history(for field: String) -> [ChangeEvent] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<ChangeEvent>(
            predicate: #Predicate { $0.fieldKey == field },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Checkpoints (revertable, named — "source control" for sliders)

    func createCheckpoint(name: String, note: String = "") {
        guard let context = modelContext else { return }
        context.insert(Checkpoint(name: name, note: note, inputs: inputs))
        try? context.save()
    }

    func allCheckpoints() -> [Checkpoint] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<Checkpoint>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func revert(to checkpoint: Checkpoint, source: String = "user") {
        let old = inputs
        for key in FireInputs.fieldKeys {
            if let oldValue = old.numericValue(for: key), let newValue = checkpoint.inputs.numericValue(for: key), oldValue != newValue {
                commitChange(field: key, from: oldValue, to: newValue, source: source)
            }
        }
        inputs = checkpoint.inputs
        persistScenario()
    }

    func deleteCheckpoint(_ checkpoint: Checkpoint) {
        guard let context = modelContext else { return }
        context.delete(checkpoint)
        try? context.save()
    }

    /// Fields that differ between the live scenario and a checkpoint — used for the diff view.
    func diff(against checkpoint: Checkpoint) -> [(field: String, current: Double, checkpoint: Double)] {
        FireInputs.fieldKeys.compactMap { key in
            guard let cur = inputs.numericValue(for: key), let chk = checkpoint.inputs.numericValue(for: key), cur != chk else { return nil }
            return (key, cur, chk)
        }
    }

    // MARK: - AI-driven slider control

    /// Applies a change requested by the assistant, logging it distinctly from manual edits.
    /// Ignores unknown field keys and clamps the value to the field's valid range when known.
    func applyAssistantChange(field: String, value: Double) {
        guard FireInputs.fieldKeys.contains(field) else { return }
        guard let old = inputs.numericValue(for: field) else { return }
        let clampedValue = FireInputs.validRanges[field].map { range in min(max(value, range.lowerBound), range.upperBound) } ?? value
        inputs = inputs.setting(field, to: clampedValue)
        commitChange(field: field, from: old, to: clampedValue, source: "assistant")
    }

    // MARK: - Assistant chat persistence

    func appendMessage(role: String, text: String) {
        guard let context = modelContext else { return }
        context.insert(AssistantMessage(role: role, text: text))
        try? context.save()
    }

    func allMessages() -> [AssistantMessage] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<AssistantMessage>(sortBy: [SortDescriptor(\.timestamp)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func allChangeEvents() -> [ChangeEvent] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<ChangeEvent>(sortBy: [SortDescriptor(\.timestamp)])
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Plan export / import

    func exportBundle() -> FirePlanBundle {
        FirePlanBundle(
            scenario: inputs,
            checkpoints: allCheckpoints(),
            changeEvents: allChangeEvents(),
            assistantMessages: allMessages()
        )
    }

    func importBundle(_ bundle: FirePlanBundle, mode: ImportMode) throws {
        guard bundle.isSupported else {
            throw FirePlanBundleError.unsupportedVersion(bundle.formatVersion)
        }

        guard let context = modelContext else { return }

        if mode == .replace {
            clearAllData(in: context)
            insertBundle(bundle, in: context, merge: false)
        } else {
            insertBundle(bundle, in: context, merge: true)
        }

        inputs = bundle.scenario
        persistScenario()
        try context.save()
    }

    private func clearAllData(in context: ModelContext) {
        for state in (try? context.fetch(FetchDescriptor<ScenarioState>())) ?? [] {
            context.delete(state)
        }
        for checkpoint in (try? context.fetch(FetchDescriptor<Checkpoint>())) ?? [] {
            context.delete(checkpoint)
        }
        for event in (try? context.fetch(FetchDescriptor<ChangeEvent>())) ?? [] {
            context.delete(event)
        }
        for message in (try? context.fetch(FetchDescriptor<AssistantMessage>())) ?? [] {
            context.delete(message)
        }
    }

    private func insertBundle(_ bundle: FirePlanBundle, in context: ModelContext, merge: Bool) {
        let existingCheckpointIDs = Set(allCheckpoints().map(\.id))
        let existingEventIDs = Set(allChangeEvents().map(\.id))
        let existingMessageIDs = Set(allMessages().map(\.id))

        if !merge {
            let state = ScenarioState(inputs: bundle.scenario)
            context.insert(state)
        }

        for dto in bundle.checkpoints where !merge || !existingCheckpointIDs.contains(dto.id) {
            context.insert(Checkpoint(id: dto.id, name: dto.name, note: dto.note, createdAt: dto.createdAt, inputs: dto.inputs))
        }

        for dto in bundle.changeEvents where !merge || !existingEventIDs.contains(dto.id) {
            context.insert(ChangeEvent(id: dto.id, timestamp: dto.timestamp, fieldKey: dto.fieldKey, oldValue: dto.oldValue, newValue: dto.newValue, source: dto.source))
        }

        for dto in bundle.assistantMessages where !merge || !existingMessageIDs.contains(dto.id) {
            context.insert(AssistantMessage(id: dto.id, timestamp: dto.timestamp, role: dto.role, text: dto.text))
        }
    }

    // MARK: - Slider bindings

    /// Produces a `Binding<Double>` for a given writable field on `inputs`, plus a matching
    /// commit handler that logs the change once the drag ends.
    func binding(_ keyPath: WritableKeyPath<FireInputs, Double>, field: String) -> Binding<Double> {
        Binding(
            get: { self.inputs[keyPath: keyPath] },
            set: { self.inputs[keyPath: keyPath] = $0 }
        )
    }

    /// Produces a `Binding<Bool>` for a toggle field on `inputs`, logging the change and
    /// autosaving on every flip (mirrors `binding(_:field:)`'s commit behavior for sliders).
    func boolBinding(_ keyPath: WritableKeyPath<FireInputs, Bool>, field: String) -> Binding<Bool> {
        Binding(
            get: { self.inputs[keyPath: keyPath] },
            set: { newValue in
                let oldValue = self.inputs[keyPath: keyPath]
                self.inputs[keyPath: keyPath] = newValue
                self.commitChange(field: field, from: oldValue ? 1 : 0, to: newValue ? 1 : 0)
                self.persistScenario()
            }
        )
    }
}
