import SwiftUI
import ArrowsCore

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var highlight: HighlightInfo?

    var body: some View {
        VStack(spacing: 20) {
            HUDView(
                level: viewModel.level,
                lives: viewModel.lives,
                remaining: viewModel.board.remaining
            )
            BoardView(
                board: viewModel.board,
                highlight: highlight?.position,
                highlightColor: highlight?.color ?? .red
            ) { position in
                handleTap(position)
            }
            .padding()
            Button {
                showHint()
            } label: {
                Label("Hint", systemImage: "lightbulb")
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.status != .playing)
            Spacer()
        }
        .navigationTitle(viewModel.isDaily ? "Daily" : "Level \(viewModel.level)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink { SettingsView() } label: { Image(systemName: "gearshape") }
            }
        }
        .overlay { resultOverlay }
        .animation(.easeInOut, value: viewModel.status)
        .animation(.easeInOut, value: highlight)
    }

    private func handleTap(_ position: Position) {
        let outcome = viewModel.tap(position)
        switch outcome {
        case .escaped:
            Haptics.escaped(); SoundFX.escaped()
            clearHighlight()
        case let .blocked(_, blocker):
            Haptics.blocked(); SoundFX.blocked()
            flash(blocker, isHint: false)
        case .ignored:
            break
        }
        if viewModel.status == .won {
            Haptics.won(); SoundFX.won()
        }
    }

    private func showHint() {
        guard let position = viewModel.hint() else { return }
        flash(position, isHint: true)
    }

    private func flash(_ position: Position, isHint: Bool) {
        highlight = HighlightInfo(position: position, isHint: isHint)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if highlight?.position == position { clearHighlight() }
        }
    }

    private func clearHighlight() {
        highlight = nil
    }

    @ViewBuilder
    private var resultOverlay: some View {
        switch viewModel.status {
        case .playing:
            EmptyView()
        case .won where viewModel.isDaily:
            ResultOverlay(
                title: "Daily done!",
                systemImage: "star.fill",
                tint: .yellow,
                primaryTitle: "Home",
                primaryAction: { dismiss() }
            )
        case .won:
            ResultOverlay(
                title: "Cleared!",
                systemImage: "checkmark.seal.fill",
                tint: .green,
                primaryTitle: "Next level",
                primaryAction: { viewModel.advanceToNextLevel(); clearHighlight() },
                secondaryTitle: "Home",
                secondaryAction: { dismiss() }
            )
        case .lost:
            ResultOverlay(
                title: "Out of lives",
                systemImage: "xmark.octagon.fill",
                tint: .red,
                primaryTitle: "Retry",
                primaryAction: { viewModel.restart(); clearHighlight() },
                secondaryTitle: "Home",
                secondaryAction: { dismiss() }
            )
        }
    }
}

private struct HighlightInfo: Equatable {
    let position: Position
    let isHint: Bool
    var color: Color { isHint ? .green : .red }
}

private struct ResultOverlay: View {
    let title: String
    let systemImage: String
    let tint: Color
    let primaryTitle: String
    let primaryAction: () -> Void
    var secondaryTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: systemImage)
                    .font(.system(size: 56))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.title.bold())
                VStack(spacing: 12) {
                    Button(primaryTitle, action: primaryAction)
                        .buttonStyle(.borderedProminent)
                    if let secondaryTitle, let secondaryAction {
                        Button(secondaryTitle, action: secondaryAction)
                            .buttonStyle(.bordered)
                    }
                }
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(40)
        }
    }
}
