import AppKit
import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let firePlan = UTType(exportedAs: "com.firesystem.fireplan")
}

enum DataPlanExporter {
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    @MainActor
    static func export(bundle: FirePlanBundle) {
        guard let data = try? encoder.encode(bundle) else { return }

        let panel = NSSavePanel()
        panel.title = "Share FIRE Plan"
        panel.nameFieldStringValue = defaultFilename()
        panel.allowedContentTypes = [.firePlan, .json]
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? data.write(to: url, options: .atomic)
    }

    @MainActor
    static func pickPlanFile() -> FirePlanBundle? {
        let panel = NSOpenPanel()
        panel.title = "Import FIRE Plan"
        panel.allowedContentTypes = [.firePlan, .json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        return load(from: url)
    }

    static func load(from url: URL) -> FirePlanBundle? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(FirePlanBundle.self, from: data)
    }

    static func validate(_ bundle: FirePlanBundle) throws {
        guard bundle.isSupported else {
            throw FirePlanBundleError.unsupportedVersion(bundle.formatVersion)
        }
    }

    private static func defaultFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: .now)
        let names = Personalization.coupleNames.replacingOccurrences(of: " & ", with: "-")
        return "\(names)-FIRE-\(date).fireplan"
    }
}
