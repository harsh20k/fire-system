import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @Environment(ThemeManager.self) private var themeManager
    @State private var apiKey: String = KeychainStore.load() ?? ""
    @State private var saved = false

    var body: some View {
        @Bindable var themeManager = themeManager

        VStack(alignment: .leading, spacing: 18) {
            Text("Settings").font(.title2.bold())

            appearanceSection(themeManager: themeManager)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                TooltipLabel(label: "Gemini API Key", tip: "Stored securely in the macOS Keychain, never written to disk in plain text. Required for the FIRE Assistant chat and AI-driven slider control.")
                    .font(.headline)
                SecureField("Paste your Gemini API key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 420)

                HStack {
                    Button("Save") {
                        KeychainStore.save(apiKey: apiKey)
                        saved = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.pine)

                    Button("Clear", role: .destructive) {
                        KeychainStore.clear()
                        apiKey = ""
                    }
                    .buttonStyle(.bordered)

                    if saved {
                        Label("Saved", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(Theme.pine)
                            .font(.caption)
                    }
                }

                Link("Get a Gemini API key from Google AI Studio", destination: URL(string: "https://aistudio.google.com/apikey")!)
                    .font(.caption)
            }

            Divider()

            Text("About")
                .font(.headline)
            Text(Personalization.aboutBlurb)
                .font(.system(.footnote, design: .serif))
                .foregroundStyle(Theme.mutedText(scheme))
                .frame(maxWidth: 420, alignment: .leading)

            Spacer()
            HStack {
                Spacer()
                Button("Done") { dismiss() }
            }
        }
        .padding(24)
        .frame(width: 480, height: 520)
        .background(Theme.paper(scheme))
        .id(themeManager.appearanceID)
    }

    @ViewBuilder
    private func appearanceSection(themeManager: ThemeManager) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Appearance")
                .font(.headline)

            HStack(spacing: 6) {
                Image(systemName: scheme == .dark ? "moon.fill" : "sun.max.fill")
                    .foregroundStyle(Theme.mutedText(scheme))
                Text("System is in \(scheme == .dark ? "Dark" : "Light") mode")
                    .font(.caption)
                    .foregroundStyle(Theme.mutedText(scheme))
            }

            Text("Light mode theme")
                .font(.subheadline.weight(.medium))
            lightThemePicker(themeManager: themeManager)

            Text("Dark mode theme")
                .font(.subheadline.weight(.medium))
            darkThemePicker(themeManager: themeManager)
        }
    }

    private func lightThemePicker(themeManager: ThemeManager) -> some View {
        HStack(spacing: 8) {
            ForEach(LightThemePreset.allCases) { preset in
                Button {
                    themeManager.lightPreset = preset
                } label: {
                    VStack(spacing: 4) {
                        let palette = Theme.palette(for: preset)
                        ThemePresetSwatch(
                            paper: palette.paper,
                            accent: palette.pine,
                            selected: themeManager.lightPreset == preset
                        )
                        Text(preset.displayName)
                            .font(.caption2)
                            .foregroundStyle(Theme.ink(scheme))
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func darkThemePicker(themeManager: ThemeManager) -> some View {
        HStack(spacing: 8) {
            ForEach(DarkThemePreset.allCases) { preset in
                Button {
                    themeManager.darkPreset = preset
                } label: {
                    VStack(spacing: 4) {
                        let palette = Theme.palette(for: preset)
                        ThemePresetSwatch(
                            paper: palette.paper,
                            accent: palette.pine,
                            selected: themeManager.darkPreset == preset
                        )
                        Text(preset.displayName)
                            .font(.caption2)
                            .foregroundStyle(Theme.ink(scheme))
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
