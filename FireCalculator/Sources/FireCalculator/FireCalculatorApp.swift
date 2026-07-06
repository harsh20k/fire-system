import SwiftUI
import SwiftData

@main
struct FireCalculatorApp: App {
    @State private var store = AppStore()
    @State private var themeManager = ThemeManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ScenarioState.self,
            Checkpoint.self,
            ChangeEvent.self,
            AssistantMessage.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(themeManager)
                .id(themeManager.appearanceID)
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 1280, height: 900)

        Settings {
            SettingsView()
                .environment(themeManager)
                .id(themeManager.appearanceID)
        }
    }
}
