import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.modelContext) private var modelContext
    @Environment(AppStore.self) private var store
    @Environment(AppActionRouter.self) private var router

    @State private var showCheckpoints = false
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var showAssistant = false
    @State private var showExport = false
    @State private var showCommandPalette = false
    @State private var showImportDialog = false
    @State private var pendingImport: FirePlanBundle?
    @State private var importError: String?

    private enum SectionGridLayout {
        case oneColumn
        case twoColumn
        case fourColumn

        init(width: CGFloat) {
            if width >= 1200 {
                self = .fourColumn
            } else if width >= 640 {
                self = .twoColumn
            } else {
                self = .oneColumn
            }
        }

        var columnCount: Int {
            switch self {
            case .oneColumn: 1
            case .twoColumn: 2
            case .fourColumn: 4
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                VStack(spacing: Theme.Spacing.section) {
                    header
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Theme.Spacing.screen)

                    ResultsPanel()
                }
                .padding(.top, Theme.Spacing.screen)
                .padding(.bottom, Theme.Spacing.inline)

                Rectangle()
                    .fill(Theme.border(scheme))
                    .frame(height: Theme.borderWidth)

                GeometryReader { outer in
                    let layout = SectionGridLayout(width: outer.size.width)
                    ScrollView {
                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(.flexible(), spacing: Theme.Spacing.section),
                                count: layout.columnCount
                            ),
                            alignment: .leading,
                            spacing: Theme.Spacing.section
                        ) {
                            TargetSection().id("target-section")
                            HomeSection().id("home-section")
                            HouseholdSection().id("household-section")
                            ExpensesSection().id("expenses-section")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Theme.Spacing.screen)
                    }
                }
            }
            .background(Theme.neutral(scheme))

            if showAssistant {
                AssistantPanel(isPresented: $showAssistant)
                    .padding(Theme.Spacing.screen)
                    .transition(.scale(scale: 0.92, anchor: .bottomTrailing).combined(with: .opacity))
                    .zIndex(1)
            }

            if showCommandPalette {
                CommandPalette(isPresented: $showCommandPalette, onSelect: handleAction)
                    .zIndex(2)
            }

            if showImportDialog, let bundle = pendingImport {
                Color.black.opacity(0.3).ignoresSafeArea().zIndex(3)
                ImportPlanDialog(
                    bundle: bundle,
                    onReplace: { importBundle(bundle, mode: .replace) },
                    onMerge: { importBundle(bundle, mode: .merge) },
                    onCancel: { cancelImport() }
                )
                .brutalistBorder()
                .zIndex(4)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: showAssistant)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                ForEach(AppShortcutRegistry.toolbarActions, id: \.rawValue) { action in
                    ShortcutToolbarButton(
                        title: action.title,
                        systemImage: action.systemImage,
                        shortcut: AppShortcutRegistry.shortcut(for: action)
                    ) {
                        handleAction(action)
                    }
                }
            }
        }
        .sheet(isPresented: $showCheckpoints) { CheckpointsView() }
        .sheet(isPresented: $showHistory) { HistoryView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showExport) { ExportPreviewView() }
        .alert("Import Failed", isPresented: Binding(
            get: { importError != nil },
            set: { if !$0 { importError = nil } }
        )) {
            Button("OK", role: .cancel) { importError = nil }
        } message: {
            Text(importError ?? "")
        }
        .onAppear { store.attach(context: modelContext) }
        .onChange(of: router.actionTick) { _, _ in
            if let action = router.consumeAction() {
                handleAction(action)
            }
        }
        .background {
            Group {
                paletteShortcutButton
                checkpointsShortcutButton
                historyShortcutButton
                exportPDFShortcutButton
                shareDataShortcutButton
                importDataShortcutButton
                assistantShortcutButton
            }
            .frame(width: 0, height: 0)
            .opacity(0)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.inline / 2) {
            BrutalText(
                text: Personalization.nestEggTagline,
                variant: .caption,
                color: Theme.mutedText(scheme),
                uppercase: true,
                tracking: 2
            )
            BrutalText(text: Personalization.coupleGreeting, variant: .title)
            BrutalText(
                text: Personalization.headerSubtitle,
                variant: .body,
                color: Theme.mutedText(scheme)
            )
        }
    }

    private func handleAction(_ action: AppAction) {
        switch action {
        case .commandPalette:
            showCommandPalette = true
        case .checkpoints:
            showCheckpoints = true
        case .history:
            showHistory = true
        case .exportPDF:
            showExport = true
        case .shareData:
            DataPlanExporter.export(bundle: store.exportBundle())
        case .importData:
            beginImport()
        case .assistant:
            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                showAssistant.toggle()
            }
        case .settings:
            showSettings = true
        case .closeSheet:
            showCheckpoints = false
            showHistory = false
            showSettings = false
            showExport = false
            showCommandPalette = false
            showAssistant = false
        }
    }

    private func beginImport() {
        guard let bundle = DataPlanExporter.pickPlanFile() else { return }
        do {
            try DataPlanExporter.validate(bundle)
            pendingImport = bundle
            showImportDialog = true
        } catch {
            importError = error.localizedDescription
        }
    }

    private func importBundle(_ bundle: FirePlanBundle, mode: ImportMode) {
        do {
            try store.importBundle(bundle, mode: mode)
            cancelImport()
        } catch {
            importError = error.localizedDescription
            cancelImport()
        }
    }

    private func cancelImport() {
        pendingImport = nil
        showImportDialog = false
    }

    @ViewBuilder
    private func hiddenShortcut(_ action: AppAction, perform: @escaping () -> Void) -> some View {
        if let shortcut = AppShortcutRegistry.shortcut(for: action) {
            Button(action: perform) { EmptyView() }
                .keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
        }
    }

    private var paletteShortcutButton: some View {
        hiddenShortcut(.commandPalette) { showCommandPalette = true }
    }

    private var checkpointsShortcutButton: some View {
        hiddenShortcut(.checkpoints) { showCheckpoints = true }
    }

    private var historyShortcutButton: some View {
        hiddenShortcut(.history) { showHistory = true }
    }

    private var exportPDFShortcutButton: some View {
        hiddenShortcut(.exportPDF) { showExport = true }
    }

    private var shareDataShortcutButton: some View {
        hiddenShortcut(.shareData) { DataPlanExporter.export(bundle: store.exportBundle()) }
    }

    private var importDataShortcutButton: some View {
        hiddenShortcut(.importData) { beginImport() }
    }

    private var assistantShortcutButton: some View {
        hiddenShortcut(.assistant) {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                showAssistant.toggle()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
        .environment(AppActionRouter())
        .modelContainer(for: [ScenarioState.self, Checkpoint.self, ChangeEvent.self, AssistantMessage.self], inMemory: true)
}
