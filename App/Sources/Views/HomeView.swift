import SwiftUI
import ArrowsCore

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Spacer()
                Text("\u{1F3F9}")
                    .font(.system(size: 84))
                Text("Arrows Offline")
                    .font(.largeTitle.bold())
                Text("Tap an arrow to fire it. Clear the board.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
                NavigationLink {
                    GameView(viewModel: GameViewModel(level: 1))
                } label: {
                    Text("Play")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.tint, in: RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 40)
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
