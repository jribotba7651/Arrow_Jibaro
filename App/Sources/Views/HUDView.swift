import SwiftUI

/// Top heads-up display: current level, remaining lives, arrows left. Hearts
/// animate out with a spring when a life is lost.
struct HUDView: View {
    let level: Int
    let lives: Int
    let remaining: Int

    var body: some View {
        HStack {
            Label("\(level)", systemImage: "flag.checkered")
            Spacer()
            HStack(spacing: 4) {
                ForEach(0..<max(lives, 0), id: \.self) { _ in
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: lives)
            Spacer()
            Label("\(remaining)", systemImage: "square.grid.3x3")
        }
        .font(.headline)
        .padding(.horizontal)
    }
}
