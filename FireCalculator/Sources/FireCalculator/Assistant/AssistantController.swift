import Foundation
import Observation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: String // "user" | "model" | "system"
    var text: String
}

/// Drives the Gemini conversation, grounding it with the current scenario snapshot and
/// applying any slider changes the model requests back onto the `AppStore`.
@Observable
final class AssistantController {
    var messages: [ChatMessage] = []
    var isLoading = false
    var lastError: String?

    private let client = GeminiClient()
    private var conversation: [GeminiTurn] = []

    func loadPersisted(from store: AppStore) {
        messages = store.allMessages().map { ChatMessage(role: $0.role, text: $0.text) }
        conversation = messages.compactMap { msg in
            guard msg.role == "user" || msg.role == "model" else { return nil }
            return GeminiTurn(role: msg.role, text: msg.text, functionCall: nil, functionResponse: nil)
        }
    }

    @MainActor
    func send(_ text: String, store: AppStore) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let userMessage = ChatMessage(role: "user", text: text)
        messages.append(userMessage)
        store.appendMessage(role: "user", text: text)
        conversation.append(GeminiTurn(role: "user", text: text, functionCall: nil, functionResponse: nil))

        await runTurn(store: store)
    }

    /// Maximum number of chained function-call turns allowed within a single `send` before
    /// we stop recursing, to avoid an unbounded chain of assistant-driven actions.
    private static let maxTurnDepth = 5

    @MainActor
    private func runTurn(store: AppStore, depth: Int = 0) async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }

        do {
            let systemPrompt = Self.systemPrompt(for: store.inputs)
            let turn = try await client.send(history: conversation, systemPrompt: systemPrompt)

            if let call = turn.functionCall {
                conversation.append(turn)
                store.applyAssistantChange(field: call.field, value: call.value)

                let confirmation = "Set \(call.field) to \(String(format: "%.2f", call.value))."
                messages.append(ChatMessage(role: "model", text: "🎚️ \(confirmation)"))
                store.appendMessage(role: "model", text: "🎚️ \(confirmation)")

                let response = GeminiTurn(role: "user", text: nil, functionCall: nil,
                                           functionResponse: GeminiFunctionResponse(name: call.name, result: ["status": "ok", "field": call.field, "value": String(call.value)]))
                conversation.append(response)

                guard depth + 1 < Self.maxTurnDepth else {
                    let message = "Reached the maximum number of chained actions for this turn."
                    messages.append(ChatMessage(role: "system", text: message))
                    store.appendMessage(role: "system", text: message)
                    return
                }
                // Let the model produce a natural-language follow-up after applying the change.
                await runTurn(store: store, depth: depth + 1)
            } else if let text = turn.text, !text.isEmpty {
                conversation.append(turn)
                messages.append(ChatMessage(role: "model", text: text))
                store.appendMessage(role: "model", text: text)
            }
        } catch {
            lastError = error.localizedDescription
            messages.append(ChatMessage(role: "system", text: "⚠️ \(error.localizedDescription)"))
        }
    }

    static func systemPrompt(for inputs: FireInputs) -> String {
        """
        You are a helpful, concise FIRE co-pilot for \(Personalization.coupleNames), a Halifax, \
        Nova Scotia couple planning financial independence together. Address them warmly as a pair \
        (use their names when natural). You can chat, explain the numbers, and — when they ask \
        you to change something — call the `set_slider` function with the exact field key and new \
        numeric value to move a slider yourself.

        Guidance to ground your suggestions (Nova Scotia, 2026): a 3.3-3.5% withdrawal rate suits a \
        40+ year retirement horizon; Halifax benchmark home price is roughly $572k; combined federal \
        + NS marginal tax runs 24%-54%; average new CPP beneficiary gets ~$925/mo, OAS max is ~$742/mo \
        reduced by residency years for newcomers; Halifax childcare averages ~$22/day, provincial \
        average ~$12/day (not the $10/day target). Recommend a 40-50% savings rate as the master lever.

        Current scenario snapshot (JSON): \(Self.snapshotJSON(inputs))

        Valid field keys for set_slider: \(FireInputs.fieldKeys.joined(separator: ", ")).
        Keep replies short (2-4 sentences) unless asked for depth. When you change a slider, briefly \
        explain why in your next message.
        """
    }

    private static func snapshotJSON(_ inputs: FireInputs) -> String {
        guard let data = try? JSONEncoder().encode(inputs), let s = String(data: data, encoding: .utf8) else { return "{}" }
        return s
    }
}
