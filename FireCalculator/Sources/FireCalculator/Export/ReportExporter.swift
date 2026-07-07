import SwiftUI
import PDFKit
import AppKit

enum ReportExporter {
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

struct ExportPreviewView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BrutalText(text: Personalization.exportPreviewTitle, variant: .title)
                Spacer()
                ShortcutLabeledButton(
                    title: "Export PDF",
                    shortcut: AppShortcutRegistry.shortcut(for: .exportPDF),
                    variant: .primary
                ) {
                    ReportExporter.exportPDF(inputs: store.inputs, results: store.results)
                }
                BrutalButton(title: "Close", variant: .secondary) { dismiss() }
                    .frame(width: 120)
            }
            .padding(Theme.Spacing.screen)

            ScrollView {
                ReportView(inputs: store.inputs, results: store.results)
                    .padding(Theme.Spacing.screen)
            }
        }
        .frame(minWidth: 760, minHeight: 700)
        .background(Theme.neutral(scheme))
        .onExitCommand { dismiss() }
    }
}
