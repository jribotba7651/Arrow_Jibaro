import SwiftUI
import ArrowsCore

struct GameView: View {
    @StateObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            HUDView(
                level: viewModel.level,
                lives: viewModel.lives,
                remaining: viewModel.board.remaining
            )
            BoardView(board: viewModel.board) { position in
                viewModel.tap(position)
            }
            .padding()
            Spacer()
        }
        .navigationTitle("Level \(viewModel.level)")
        .navigationBarTitleDisplayMode(.inline)
        .overlay { resultOverlay }
        .animation(.easeInOut, value: viewModel.status)
    }

    @ViewBuilder
    private var resultOverlay: some View {
        switch viewModel.status {
        case .playing:
            EmptyView()
        case .won:
            ResultOverlay(
                title: "Cleared!",
                systemImage: "checkmark.seal.fill",
                tint: .green,
                primaryTitle: "Next level",
                primaryAction: { viewModel.advanceToNextLevel() },
                secondaryTitle: "Home",
                secondaryAction: { dismiss() }
            )
        case .lost:
            ResultOverlay(
                title: "Out of lives",
                systemImage: "xmark.octagon.fill",
                tint: .red,
                primaryTitle: "Retry",
                primaryAction: { viewModel.restart() },
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
    let secondaryTitle: String
    let secondaryAction: () -> Void

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
                    Button(secondaryTitle, action: secondaryAction)
                        .buttonStyle(.bordered)
                }
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(40)
        }
    }
}
