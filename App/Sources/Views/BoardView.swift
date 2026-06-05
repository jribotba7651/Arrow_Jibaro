import SwiftUI
import ArrowsCore

/// Renders the NxN grid with deterministic cell geometry and owns the in-board
/// gameplay feedback: flying-arrow shots on escape, a shake + red flash on
/// collision, and a pulsing green hint. Taps are reported through `onTap`,
/// which returns the resolved outcome so the board can animate it.
struct BoardView: View {
    let board: Board
    var hint: Position? = nil
    let onTap: (Position) -> TapOutcome

    @State private var projectiles: [Projectile] = []
    @State private var collision: Position?
    @State private var shake: CGFloat = 0

    private let spacing: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let count = CGFloat(board.size)
            let cellSize = (side - spacing * (count - 1)) / count
            ZStack(alignment: .topLeading) {
                ForEach(allPositions, id: \.self) { position in
                    cellView(at: position, size: cellSize)
                        .frame(width: cellSize, height: cellSize)
                        .offset(x: origin(position.col, cellSize),
                                y: origin(position.row, cellSize))
                }
                ForEach(projectiles) { projectile in
                    FlyingArrowView(direction: projectile.direction, cellSize: cellSize) {
                        projectiles.removeAll { $0.id == projectile.id }
                    }
                    .frame(width: cellSize, height: cellSize)
                    .offset(x: origin(projectile.start.col, cellSize),
                            y: origin(projectile.start.row, cellSize))
                    .allowsHitTesting(false)
                }
            }
            .frame(width: side, height: side, alignment: .topLeading)
            .modifier(ShakeEffect(animatableData: shake))
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var allPositions: [Position] {
        (0..<board.size).flatMap { row in
            (0..<board.size).map { Position(row: row, col: $0) }
        }
    }

    private func origin(_ index: Int, _ cellSize: CGFloat) -> CGFloat {
        CGFloat(index) * (cellSize + spacing)
    }

    @ViewBuilder
    private func cellView(at position: Position, size: CGFloat) -> some View {
        let arrow = board.arrow(at: position)
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(fillColor(position, hasArrow: arrow != nil))
            if position == collision {
                RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 3)
            } else if position == hint {
                HintRing()
            }
            if let arrow {
                ArrowView(direction: arrow.direction)
                    .padding(size * 0.16)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { if arrow != nil { handleTap(position) } }
    }

    private func fillColor(_ position: Position, hasArrow: Bool) -> Color {
        if position == collision { return Color.red.opacity(0.22) }
        if position == hint { return Color.green.opacity(0.18) }
        return hasArrow ? Color.accentColor.opacity(0.16) : Color.gray.opacity(0.12)
    }

    private func handleTap(_ position: Position) {
        let direction = board.arrow(at: position)?.direction
        let outcome = onTap(position)
        switch outcome {
        case .escaped:
            if let direction {
                projectiles.append(Projectile(start: position, direction: direction))
            }
        case let .blocked(_, blocker):
            collision = blocker
            withAnimation(.linear(duration: 0.45)) { shake += 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if collision == blocker { collision = nil }
            }
        case .ignored:
            break
        }
    }
}

private struct Projectile: Identifiable {
    let id = UUID()
    let start: Position
    let direction: Direction
}

/// A green ring that gently pulses to point out the suggested move.
private struct HintRing: View {
    @State private var pulse = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.green, lineWidth: 3)
            .scaleEffect(pulse ? 1.0 : 0.86)
            .opacity(pulse ? 1.0 : 0.4)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}
