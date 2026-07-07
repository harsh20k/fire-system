import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @State private var apiKey: String = KeychainStore.load() ?? ""
    @State private var saved = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
            BrutalText(text: "Settings", variant: .title)

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
                    BrutalCard {
                        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
                            HStack(spacing: 6) {
                                Image(systemName: scheme == .dark ? "moon.fill" : "sun.max.fill")
                                    .foregroundStyle(Theme.mutedText(scheme))
                                BrutalText(
                                    text: "Follows system \(scheme == .dark ? "dark" : "light") mode",
                                    variant: .caption,
                                    color: Theme.mutedText(scheme)
                                )
                            }
                            BrutalText(
                                text: "Brutalist theme — high contrast, blocky cards, airy spacing.",
                                variant: .caption,
                                color: Theme.mutedText(scheme)
                            )
                        }
                    }

                    BrutalCard {
                        VStack(alignment: .leading, spacing: Theme.Spacing.inline) {
                            TooltipLabel(label: "Gemini API Key", tip: "Stored securely in the macOS Keychain. Required for the FIRE Assistant and AI-driven slider control.")
                                .font(Theme.Typography.body)
                                .fontWeight(.semibold)
                            SecureField("Paste your Gemini API key", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 420)

                            HStack(spacing: 12) {
                                BrutalButton(title: "Save", variant: .primary) {
                                    KeychainStore.save(apiKey: apiKey)
                                    saved = true
                                }
                                .frame(width: 120)

                                BrutalButton(title: "Clear", variant: .secondary) {
                                    KeychainStore.clear()
                                    apiKey = ""
                                }
                                .frame(width: 120)

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

                    BrutalCard {
                        VStack(alignment: .leading, spacing: 8) {
                            BrutalText(text: "About", variant: .body, bold: true)
                            BrutalText(text: Personalization.aboutBlurb, variant: .caption, color: Theme.mutedText(scheme))
                        }
                    }
                }
            }

            HStack {
                Spacer()
                BrutalButton(title: "Done", variant: .secondary) { dismiss() }
                    .frame(width: 140)
            }
            .padding(.top, Theme.Spacing.inline)
        }
        .padding(Theme.Spacing.screen)
        .padding(.bottom, Theme.shadowOffset)
        .frame(width: 480)
        .frame(minHeight: 520, maxHeight: 620)
        .background(Theme.neutral(scheme))
    }
}
