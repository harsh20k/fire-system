import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.modelContext) private var modelContext
    @Environment(AppStore.self) private var store
    @State private var showCheckpoints = false
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var showAssistant = false
    @State private var showExport = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    header

                    HStack(alignment: .top, spacing: 32) {
                        ScrollView {
                            VStack(spacing: 24) {
                                TargetSection()
                                    .id("target-section")
                                HomeSection()
                                    .id("home-section")
                                HouseholdSection()
                                    .id("household-section")
                                ExpensesSection()
                                    .id("expenses-section")
                            }
                            .padding(24)
                            .padding(.top, 0)
                        }
                        .frame(minWidth: 380, idealWidth: 440, maxWidth: 480)

                        ScrollView {
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                ResultsPanel()
                                    .frame(maxWidth: 580)
                                    .frame(maxWidth: .infinity)
                                Spacer(minLength: 0)
                            }
                            .frame(minHeight: max(0, geo.size.height - headerHeight - 48))
                            .padding(24)
                            .padding(.leading, 0)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Theme.paper(scheme))

                if showAssistant {
                    AssistantPanel(isPresented: $showAssistant)
                        .padding(24)
                        .transition(.scale(scale: 0.92, anchor: .bottomTrailing).combined(with: .opacity))
                        .zIndex(1)
                }
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: showAssistant)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button { showCheckpoints = true } label: { Label("Checkpoints", systemImage: "clock.arrow.circlepath") }
                Button { showHistory = true } label: { Label("History", systemImage: "chart.xyaxis.line") }
                Button { showExport = true } label: { Label("Export PDF", systemImage: "square.and.arrow.up") }
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                        showAssistant.toggle()
                    }
                } label: {
                    Label("Assistant", systemImage: "sparkles")
                }
                Button { showSettings = true } label: { Label("Settings", systemImage: "gearshape") }
            }
        }
        .sheet(isPresented: $showCheckpoints) { CheckpointsView() }
        .sheet(isPresented: $showHistory) { HistoryView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showExport) { ExportPreviewView() }
        .onAppear { store.attach(context: modelContext) }
    }

    private var headerHeight: CGFloat { 140 }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Personalization.nestEggTagline.uppercased())
                .font(Theme.monoSmall)
                .tracking(2)
                .foregroundStyle(Theme.mutedText(scheme))
            Text(Personalization.coupleGreeting)
                .font(.system(size: 38, weight: .bold, design: .serif))
                .foregroundStyle(Theme.ink(scheme))
            Text(Personalization.headerSubtitle)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Theme.mutedText(scheme))
                .frame(maxWidth: 600, alignment: .leading)
        }
        .padding(24)
        .padding(.bottom, 0)
    }
}

#Preview {
    ContentView()
        .environment(AppStore())
        .modelContainer(for: [ScenarioState.self, Checkpoint.self, ChangeEvent.self, AssistantMessage.self], inMemory: true)
}
