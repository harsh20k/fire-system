import SwiftUI

struct CommandPalette: View {
    @Environment(\.colorScheme) private var scheme
    @Binding var isPresented: Bool
    let onSelect: (AppAction) -> Void

    @State private var query = ""
    @State private var selectedIndex = 0
    @FocusState private var focused: Bool

    private var filteredActions: [AppAction] {
        let actions = AppShortcutRegistry.paletteActions
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return actions }
        return actions.filter {
            $0.title.lowercased().contains(q) || $0.paletteSection.lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.mutedText(scheme))
                    TextField("Search actions…", text: $query)
                        .textFieldStyle(.plain)
                        .font(Theme.Typography.body)
                        .focused($focused)
                        .onSubmit { executeSelected() }
                }
                .padding(Theme.Spacing.inline)
                .background(Theme.neutral(scheme))

                Divider()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(filteredActions.enumerated()), id: \.element.id) { index, action in
                            paletteRow(action, selected: index == selectedIndex)
                                .onTapGesture {
                                    selectedIndex = index
                                    execute(action)
                                }
                        }
                    }
                }
                .frame(maxHeight: 320)
            }
            .frame(width: 480)
            .background(Theme.surface(scheme))
            .brutalistBorder()
            .onAppear {
                focused = true
                selectedIndex = 0
            }
            .onChange(of: query) {
                selectedIndex = 0
            }
            .onKeyPress(.upArrow) {
                if selectedIndex > 0 { selectedIndex -= 1 }
                return .handled
            }
            .onKeyPress(.downArrow) {
                if selectedIndex < filteredActions.count - 1 { selectedIndex += 1 }
                return .handled
            }
            .onKeyPress(.escape) {
                dismiss()
                return .handled
            }
            .onKeyPress(.return) {
                executeSelected()
                return .handled
            }
        }
    }

    private func paletteRow(_ action: AppAction, selected: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: action.systemImage)
                .frame(width: 18)
                .foregroundStyle(Theme.mutedText(scheme))
            VStack(alignment: .leading, spacing: 2) {
                BrutalText(text: action.title, variant: .body, bold: selected)
                BrutalText(text: action.paletteSection, variant: .caption, color: Theme.mutedText(scheme))
            }
            Spacer()
            if let shortcut = AppShortcutRegistry.shortcut(for: action) {
                ShortcutBadge(text: shortcut.displayString)
            }
        }
        .padding(.horizontal, Theme.Spacing.inline)
        .padding(.vertical, 10)
        .background(selected ? Theme.primary.opacity(0.08) : Color.clear)
    }

    private func executeSelected() {
        guard filteredActions.indices.contains(selectedIndex) else { return }
        execute(filteredActions[selectedIndex])
    }

    private func execute(_ action: AppAction) {
        dismiss()
        onSelect(action)
    }

    private func dismiss() {
        isPresented = false
        query = ""
    }
}
