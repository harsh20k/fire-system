import SwiftUI

struct AssistantPanel: View {
    @Binding var isPresented: Bool

    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var controller = AssistantController()
    @State private var draft: String = ""
    @State private var dragOffset: CGSize = .zero
    @State private var accumulatedOffset: CGSize = .zero
    @FocusState private var inputFocused: Bool

    private let panelWidth: CGFloat = 440
    private let panelHeight: CGFloat = 500

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            Rectangle().fill(Theme.border(scheme)).frame(height: Theme.borderWidth)
            chatArea
            Rectangle().fill(Theme.border(scheme)).frame(height: Theme.borderWidth)
            inputBar
        }
        .frame(width: panelWidth, height: panelHeight)
        .background(Theme.surface(scheme))
        .brutalistBorder()
        .offset(dragOffset)
        .onAppear {
            controller.loadPersisted(from: store)
            inputFocused = true
        }
    }

    private var titleBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.primary)
                .symbolEffect(.pulse, options: .repeating, isActive: controller.isLoading)

            BrutalText(text: Personalization.assistantTitle, variant: .body, bold: true)

            Spacer()

            if controller.isLoading {
                ProgressView().controlSize(.small)
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    isPresented = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.ink(scheme))
                    .padding(6)
                    .background(Theme.neutral(scheme))
                    .brutalistBorder()
            }
            .buttonStyle(.plain)
            .help("Close assistant")
        }
        .padding(.horizontal, Theme.Spacing.inline)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .gesture(dragGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                dragOffset = CGSize(
                    width: accumulatedOffset.width + value.translation.width,
                    height: accumulatedOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                accumulatedOffset = dragOffset
            }
    }

    private var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if controller.messages.isEmpty {
                        BrutalText(text: Personalization.assistantWelcome, variant: .caption, color: Theme.mutedText(scheme))
                    }
                    ForEach(controller.messages) { message in
                        bubble(message)
                            .id(message.id)
                    }
                    if controller.isLoading {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            BrutalText(text: "Thinking…", variant: .caption, color: Theme.mutedText(scheme))
                        }
                    }
                }
                .padding(Theme.Spacing.inline)
            }
            .onChange(of: controller.messages) {
                if let last = controller.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private var inputBar: some View {
        VStack(alignment: .trailing, spacing: 12) {
            ZStack(alignment: .topLeading) {
                if draft.isEmpty {
                    Text("Message the assistant…")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.mutedText(scheme))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $draft)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.ink(scheme))
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(minHeight: 72, maxHeight: 120)
                    .focused($inputFocused)
            }
            .background(Theme.neutral(scheme))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .strokeBorder(Theme.border(scheme), lineWidth: Theme.borderWidth)
            }

            Button { send() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up")
                    BrutalText(text: "Send", variant: .caption, bold: true, color: .white, uppercase: true)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Theme.primaryGradient)
                .brutalistBorder()
            }
            .buttonStyle(.plain)
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || controller.isLoading)
        }
        .padding(Theme.Spacing.inline)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""
        Task { await controller.send(text, store: store) }
        inputFocused = true
    }

    @ViewBuilder
    private func bubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == "user" { Spacer(minLength: 30) }
            BrutalText(
                text: message.text,
                variant: .body,
                color: message.role == "user" ? .white : Theme.ink(scheme)
            )
            .padding(12)
            .background { bubbleBackground(for: message.role) }
            .brutalistBorder()
            if message.role != "user" { Spacer(minLength: 30) }
        }
    }

    @ViewBuilder
    private func bubbleBackground(for role: String) -> some View {
        switch role {
        case "user": Theme.primaryGradient
        case "system": Theme.accent.opacity(0.15)
        default: Theme.neutral(scheme)
        }
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Theme.neutral(.light).ignoresSafeArea()
        AssistantPanel(isPresented: .constant(true))
            .padding(24)
    }
    .environment(AppStore())
}
