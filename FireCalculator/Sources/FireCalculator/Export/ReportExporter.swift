import SwiftUI
import PDFKit
import AppKit

enum ReportExporter {
    /// Renders the given SwiftUI report into a single-page-per-section PDF using ImageRenderer,
    /// then writes it to disk via a save panel.
    @MainActor
    static func exportPDF(inputs: FireInputs, results: FireResults) {
        let report = ReportView(inputs: inputs, results: results)
        let renderer = ImageRenderer(content: report)
        renderer.scale = 2.0

        guard let nsImage = renderer.nsImage else { return }

        let pdfDocument = PDFDocument()
        if let page = PDFPage(image: nsImage) {
            pdfDocument.insert(page, at: 0)
        }

        let panel = NSSavePanel()
        panel.title = "Export FIRE Report"
        panel.nameFieldStringValue = "FIRE-Report-\(Int(Date().timeIntervalSince1970)).pdf"
        panel.allowedContentTypes = [.pdf]

        if panel.runModal() == .OK, let url = panel.url {
            pdfDocument.write(to: url)
        }
    }
}

/// Sheet that previews the report and offers the export action.
struct ExportPreviewView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(Personalization.exportPreviewTitle).font(.title2.bold())
                Spacer()
                Button("Export as PDF…") {
                    ReportExporter.exportPDF(inputs: store.inputs, results: store.results)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.pine)
                Button("Close") { dismiss() }
            }
            .padding()

            ScrollView {
                ReportView(inputs: store.inputs, results: store.results)
                    .padding()
            }
        }
        .frame(minWidth: 760, minHeight: 700)
    }
}
