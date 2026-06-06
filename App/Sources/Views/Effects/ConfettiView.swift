import SwiftUI

/// A one-shot confetti burst: colored pieces fall and fade. Purely decorative
/// and non-interactive.
struct ConfettiView: View {
    private let pieces: [ConfettiPiece]
    @State private var dropped = false

    init(count: Int = 70) {
        pieces = (0..<count).map { _ in ConfettiPiece.random() }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.6)
                        .rotationEffect(.degrees(dropped ? piece.spin : 0))
                        .position(
                            x: piece.x * geo.size.width,
                            y: dropped ? geo.size.height + 60 : -60
                        )
                        .opacity(dropped ? 0 : 1)
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: dropped
                        )
                }
            }
            .onAppear { dropped = true }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let size: CGFloat
    let color: Color
    let spin: Double
    let duration: Double
    let delay: Double

    static func random() -> ConfettiPiece {
        let palette: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return ConfettiPiece(
            x: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 7...12),
            color: palette.randomElement() ?? .blue,
            spin: Double.random(in: 180...720),
            duration: Double.random(in: 1.4...2.6),
            delay: Double.random(in: 0...0.5)
        )
    }
}
