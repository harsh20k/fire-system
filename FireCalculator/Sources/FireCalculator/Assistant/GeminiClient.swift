import Foundation

/// A single turn to send/receive from Gemini's `generateContent` REST endpoint.
struct GeminiTurn {
    let role: String // "user" | "model"
    let text: String?
    let functionCall: GeminiFunctionCall?
    let functionResponse: GeminiFunctionResponse?
}

struct GeminiFunctionCall {
    let name: String
    let field: String
    let value: Double
}

struct GeminiFunctionResponse {
    let name: String
    let result: [String: String]
}

enum GeminiError: Error, LocalizedError {
    case missingAPIKey
    case badResponse(String)
    case malformedFunctionArgs(String)
    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "No Gemini API key set. Add one in Settings."
        case .badResponse(let s): return "Gemini request failed: \(s)"
        case .malformedFunctionArgs(let s): return "Assistant requested an invalid slider change: \(s)"
        }
    }
}

/// Thin REST client for Gemini's `generateContent`, with function-calling declarations
/// that let the model directly move the app's sliders.
final class GeminiClient: @unchecked Sendable {
    private let model = "gemini-2.5-flash"

    private var apiKey: String? { KeychainStore.load() }

    /// Sends the full conversation plus a system prompt describing current scenario state,
    /// and returns either assistant text or a requested function call (slider change).
    func send(history: [GeminiTurn], systemPrompt: String) async throws -> GeminiTurn {
        guard let apiKey, !apiKey.isEmpty else { throw GeminiError.missingAPIKey }

        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)") else {
            throw GeminiError.badResponse("invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "systemInstruction": ["parts": [["text": systemPrompt]]],
            "contents": history.map(contentJSON),
            "tools": [["functionDeclarations": [setSliderDeclaration]]],
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "unknown error"
            throw GeminiError.badResponse(msg)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            throw GeminiError.badResponse("unexpected response shape")
        }

        var malformedCallName: String?
        for part in parts {
            if let functionCall = part["functionCall"] as? [String: Any],
               let name = functionCall["name"] as? String,
               let args = functionCall["args"] as? [String: Any],
               let field = args["field"] as? String {
                let rawValue = args["value"]
                let value: Double?
                if let d = rawValue as? Double { value = d }
                else if let n = rawValue as? NSNumber { value = n.doubleValue }
                else if let s = rawValue as? String, let d = Double(s) { value = d }
                else { value = nil }

                guard let value else {
                    malformedCallName = name
                    continue
                }
                return GeminiTurn(role: "model", text: nil, functionCall: GeminiFunctionCall(name: name, field: field, value: value), functionResponse: nil)
            }
        }

        let text = parts.compactMap { $0["text"] as? String }.joined()
        if text.isEmpty, let malformedCallName {
            throw GeminiError.malformedFunctionArgs("\(malformedCallName) had a missing or non-numeric value")
        }
        return GeminiTurn(role: "model", text: text, functionCall: nil, functionResponse: nil)
    }

    private func contentJSON(for turn: GeminiTurn) -> [String: Any] {
        if let call = turn.functionCall {
            return ["role": turn.role, "parts": [["functionCall": ["name": call.name, "args": ["field": call.field, "value": call.value]]]]]
        }
        if let response = turn.functionResponse {
            return ["role": "function", "parts": [["functionResponse": ["name": response.name, "response": response.result]]]]
        }
        return ["role": turn.role, "parts": [["text": turn.text ?? ""]]]
    }

    /// Tool declaration allowing the model to move any named slider to a numeric value.
    private var setSliderDeclaration: [String: Any] {
        [
            "name": "set_slider",
            "description": "Sets a FIRE calculator slider/dial to a new numeric value. Field names match the app's input keys (e.g. income, savings, withdrawalRate, growthRate, homePrice, downPct, mortgageRate, amort, raisePct, promoBumpPct, promoCycle, kids, inflationRate, annualExpenses, groceries, eatingOut, etc). Boolean toggles (showRealDollars, pensionBridgeEnabled) use 1 for true and 0 for false.",
            "parameters": [
                "type": "OBJECT",
                "properties": [
                    "field": ["type": "STRING", "description": "The exact field key to change, e.g. \"withdrawalRate\"."],
                    "value": ["type": "NUMBER", "description": "The new numeric value for that field."],
                ],
                "required": ["field", "value"],
            ],
        ]
    }
}
