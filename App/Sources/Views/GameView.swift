import SwiftUI
import ArrowsCore

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var hintCell: Position?

    var body: some View {
        VStack(spacing: 8) {
            HUDView(
                level: viewModel.level,
                lives: viewModel.lives,
                remaining: viewModel.board.remaining
            )
            BoardView(board: viewModel.board, hint: hintCell) { position in
                handleTap(position)
            }
            .id(viewModel.level)
            .padding(.horizontal, 6)
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
        .overlay { if viewModel.status == .won { ConfettiView() } }
        .overlay { resultOverlay }
        .animation(.easeInOut, value: viewModel.status)
    }

    @discardableResult
    private func handleTap(_ position: Position) -> TapOutcome {
        let outcome = viewModel.tap(position)
        switch outcome {
        case .escaped: Haptics.escaped(); SoundFX.escaped()
        case .blocked: Haptics.blocked(); SoundFX.blocked()
        case .ignored: break
        }
        if viewModel.status == .won { Haptics.won(); SoundFX.won() }
        return outcome
    }

    private func showHint() {
        guard let position = viewModel.hint() else { return }
        hintCell = position
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if hintCell == position { hintCell = nil }
        }
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
                primaryAction: { hintCell = nil; viewModel.advanceToNextLevel() },
                secondaryTitle: "Home",
                secondaryAction: { dismiss() }
            )
        case .lost:
            ResultOverlay(
                title: "Out of lives",
                systemImage: "xmark.octagon.fill",
                tint: .red,
                primaryTitle: "Retry",
                primaryAction: { hintCell = nil; viewModel.restart() },
                secondaryTitle: "Home",
                secondaryAction: { dismiss() }
            )
        }
    }
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
