import SwiftUI

/// Floating HUD chat panel: converse with Gemini, which can also directly move sliders
/// via function calling (visibly confirmed with a 🎚️ message).
struct AssistantPanel: View {
    @Binding var isPresented: Bool

    @Environment(AppStore.self) private var store
    @Environment(\.colorScheme) private var scheme
    @State private var controller = AssistantController()
    @State private var draft: String = ""
    @State private var dragOffset: CGSize = .zero
    @State private var accumulatedOffset: CGSize = .zero
    @State private var headerGlow = false

    private let panelWidth: CGFloat = 340
    private let panelHeight: CGFloat = 460
    private let cornerRadius: CGFloat = 16

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            Divider().opacity(0.5)
            chatArea
            Divider().opacity(0.5)
            inputBar
        }
        .frame(width: panelWidth, height: panelHeight)
        .background(Theme.card(scheme).opacity(0.35))
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Theme.hairline(scheme), lineWidth: 1)
        }
        .overlay {
            if controller.isLoading {
                ShimmerBorder(cornerRadius: cornerRadius)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(scheme == .dark ? 0.45 : 0.18), radius: 24, y: 10)
        .offset(dragOffset)
        .onAppear { controller.loadPersisted(from: store) }
        .onChange(of: controller.isLoading) { _, loading in
            if loading {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    headerGlow = true
                }
            } else {
                headerGlow = false
            }
        }
    }

    // MARK: - Title bar (drag handle)

    private var titleBar: some View {
        ZStack {
            if controller.isLoading {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Theme.pine.opacity(0.35), Theme.pine.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(height: 44)
                    .blur(radius: 12)
                    .opacity(headerGlow ? 1 : 0.35)
                    .allowsHitTesting(false)
            }

            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.pine)
                    .symbolEffect(.pulse, options: .repeating, isActive: controller.isLoading)

                Text(Personalization.assistantTitle)
                    .font(.system(.subheadline, design: .serif))
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.ink(scheme))

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.mutedText(scheme).opacity(0.7))
                }
                .buttonStyle(.plain)
                .help("Close assistant")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
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

    // MARK: - Chat

    private var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if controller.messages.isEmpty {
                        Text(Personalization.assistantWelcome)
                            .font(.system(.footnote, design: .serif))
                            .foregroundStyle(Theme.mutedText(scheme))
                    }
                    ForEach(controller.messages) { message in
                        bubble(message)
                            .id(message.id)
                    }
                    if controller.isLoading {
                        HStack(spacing: 6) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Thinking…")
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(Theme.mutedText(scheme))
                        }
                    }
                }
                .padding(14)
            }
            .onChange(of: controller.messages) {
                if let last = controller.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Message the assistant…", text: $draft, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .onSubmit(send)
            Button {
                send()
            } label: {
                Image(systemName: "arrow.up.circle.fill").font(.title2)
            }
            .buttonStyle(.plain)
            .tint(Theme.pine)
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || controller.isLoading)
        }
        .padding(12)
    }

    private func send() {
        let text = draft
        draft = ""
        Task { await controller.send(text, store: store) }
    }

    @ViewBuilder
    private func bubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == "user" { Spacer(minLength: 30) }
            Text(message.text)
                .font(.system(.callout, design: .serif))
                .padding(10)
                .background(bubbleColor(for: message.role))
                .foregroundStyle(message.role == "user" ? .white : Theme.ink(scheme))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            if message.role != "user" { Spacer(minLength: 30) }
        }
    }

    private func bubbleColor(for role: String) -> Color {
        switch role {
        case "user": return Theme.pine
        case "system": return Theme.brick.opacity(0.15)
        default: return Theme.card(scheme)
        }
    }
}

// MARK: - Loading shimmer border

private struct ShimmerBorder: View {
    var cornerRadius: CGFloat

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let cycle = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.5) / 2.5
            let angle = Angle.degrees(cycle * 360)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            Theme.pine.opacity(0.12),
                            Theme.pine.opacity(0.75),
                            Theme.slate.opacity(0.45),
                            Theme.pine.opacity(0.12),
                        ],
                        center: .center,
                        angle: angle
                    ),
                    lineWidth: 1.5
                )
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Theme.paper(.light).ignoresSafeArea()
        AssistantPanel(isPresented: .constant(true))
            .padding(24)
    }
    .environment(AppStore())
}
