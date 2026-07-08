import SwiftUI

/// Top-level tab navigation: Calculator (main FIRE planner) and Education.
struct RootView: View {
    private enum Tab: String, CaseIterable {
        case calculator, education

        var title: String {
            switch self {
            case .calculator: "Calculator"
            case .education: "Education"
            }
        }

        var systemImage: String {
            switch self {
            case .calculator: "slider.horizontal.3"
            case .education: "book.fill"
            }
        }
    }

    @State private var selectedTab: Tab = .calculator

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem { Label(Tab.calculator.title, systemImage: Tab.calculator.systemImage) }
                .tag(Tab.calculator)

            EducationView()
                .tabItem { Label(Tab.education.title, systemImage: Tab.education.systemImage) }
                .tag(Tab.education)
        }
    }
}

#Preview {
    RootView()
        .environment(AppStore())
        .environment(AppActionRouter())
        .environment(ThemeManager())
        .modelContainer(for: [ScenarioState.self, Checkpoint.self, ChangeEvent.self, AssistantMessage.self], inMemory: true)
}
