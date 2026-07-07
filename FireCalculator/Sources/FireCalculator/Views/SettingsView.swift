import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @Environment(ThemeManager.self) private var themeManager
    @State private var apiKey: String = KeychainStore.load() ?? ""
    @State private var saved = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
            BrutalText(text: "Settings", variant: .title)

            HStack(alignment: .top, spacing: Theme.Spacing.inline) {
                BrutalCard {
                    VStack(alignment: .leading, spacing: 12) {
                        BrutalText(text: "Appearance", variant: .body, bold: true)
                        Picker("Appearance", selection: Binding(
                            get: { themeManager.prefersLight },
                            set: { themeManager.prefersLight = $0 }
                        )) {
                            Text("Light").tag(true)
                            Text("Dark").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }
                }
                .frame(maxWidth: .infinity)

                BrutalCard {
                    VStack(alignment: .leading, spacing: 8) {
                        BrutalText(text: "About", variant: .body, bold: true)
                        BrutalText(text: Personalization.aboutBlurb, variant: .caption, color: Theme.mutedText(scheme))
                    }
                }
                .frame(maxWidth: .infinity)
            }

            BrutalCard {
                VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
                    TooltipLabel(label: "Gemini API Key", tip: "Stored securely in the macOS Keychain.")
                        .font(Theme.Typography.body)
                        .fontWeight(.semibold)
                    SecureField("Paste your Gemini API key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)

                    HStack(spacing: 12) {
                        BrutalButton(title: "Save", variant: .primary) {
                            KeychainStore.save(apiKey: apiKey)
                            saved = true
                        }
                        .frame(width: 100)

                        BrutalButton(title: "Clear", variant: .secondary) {
                            KeychainStore.clear()
                            apiKey = ""
                        }
                        .frame(width: 100)

                        if saved {
                            Label("Saved", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(Theme.primary)
                                .font(Theme.Typography.caption)
                        }
                    }

                    Link("Get a Gemini API key from Google AI Studio", destination: URL(string: "https://aistudio.google.com/apikey")!)
                        .font(Theme.Typography.caption)
                }
            }

            HStack {
                Spacer()
                BrutalButton(title: "Done", variant: .secondary) { dismiss() }
                    .frame(width: 120)
            }
        }
        .padding(Theme.Spacing.screen)
        .padding(.bottom, Theme.shadowOffset)
        .frame(width: 520, height: 520)
        .background(Theme.neutral(scheme))
    }
}
