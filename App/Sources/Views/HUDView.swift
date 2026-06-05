import SwiftUI

/// Top heads-up display: current level, remaining lives, arrows left.
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
                }
            }
            Spacer()
            Label("\(remaining)", systemImage: "square.grid.3x3")
        }
        .font(.headline)
        .padding(.horizontal)
    }
}
