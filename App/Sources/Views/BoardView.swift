import SwiftUI
import ArrowsCore

/// Renders the board as a maze of connected snake pieces — one continuous
/// rounded line per piece through its cell centers, with a chevron head — on a
/// dotted background. Taps any cell of a piece; escaped pieces slide off.
struct BoardView: View {
    let board: Board
    var hint: Position? = nil
    let onTap: (Position) -> TapOutcome

    @State private var collisionPieceID: Int?
    @State private var shake: CGFloat = 0
    @State private var ghosts: [Ghost] = []
    @AppStorage(SettingsKey.skin) private var skinRaw = ArrowSkin.classic.rawValue

    private let spacing: CGFloat = 0
    private var skinTint: Color { (ArrowSkin(rawValue: skinRaw) ?? .classic).tint }

    var body: some View {
        GeometryReader { geo in
            let side = max(1, min(geo.size.width, geo.size.height))
            let count = CGFloat(board.size)
            let cellSize = max(1, (side - spacing * (count - 1)) / count)
            ZStack(alignment: .topLeading) {
                ForEach(board.pieceIDsInOrder, id: \.self) { id in
                    if let piece = board.pieces[id] {
                        PiecePath(cells: piece.cells, headDirection: piece.headDirection,
                                  cellSize: cellSize, spacing: spacing)
                            .stroke(color(for: piece), style: strokeStyle(cellSize))
                            .frame(width: side, height: side, alignment: .topLeading)
                    }
                }
                ForEach(board.pieceIDsInOrder, id: \.self) { id in
                    if let piece = board.pieces[id] {
                        ForEach(Array(piece.cells.enumerated()), id: \.offset) { _, cell in
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                                .contentShape(Rectangle())
                                .offset(x: origin(cell.col, cellSize), y: origin(cell.row, cellSize))
                                .onTapGesture { handleTap(piece) }
                        }
                    }
                }
                ForEach(ghosts) { ghost in
                    GhostPieceView(piece: ghost.piece, cellSize: cellSize, spacing: spacing,
                                   side: side, color: skinTint) {
                        ghosts.removeAll { $0.id == ghost.id }
                    }
                }
            }
            .frame(width: side, height: side, alignment: .topLeading)
            .background(DotGrid(cellSize: cellSize))
            .modifier(ShakeEffect(animatableData: shake))
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func strokeStyle(_ cellSize: CGFloat) -> StrokeStyle {
        StrokeStyle(lineWidth: max(1, cellSize * 0.10), lineCap: .round, lineJoin: .round)
    }

    private func origin(_ index: Int, _ cellSize: CGFloat) -> CGFloat {
        CGFloat(index) * (cellSize + spacing)
    }

    private var hintPieceID: Int? {
        guard let hint else { return nil }
        return board.piece(at: hint)?.id
    }

    private func color(for piece: Piece) -> Color {
        if piece.id == collisionPieceID { return .red }
        if piece.id == hintPieceID { return .green }
        return skinTint
    }

    private func handleTap(_ piece: Piece) {
        let outcome = onTap(piece.head)
        switch outcome {
        case .escaped:
            ghosts.append(Ghost(piece: piece))
        case let .blocked(_, blockerID):
            collisionPieceID = blockerID
            withAnimation(.linear(duration: 0.45)) { shake += 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if collisionPieceID == blockerID { collisionPieceID = nil }
            }
        case .ignored:
            break
        }
    }
}

private struct Ghost: Identifiable {
    let id = UUID()
    let piece: Piece
}

/// A piece sliding off the board in its head direction, then fading out.
private struct GhostPieceView: View {
    let piece: Piece
    let cellSize: CGFloat
    let spacing: CGFloat
    let side: CGFloat
    let color: Color
    let onDone: () -> Void

    @State private var progress: CGFloat = 0

    var body: some View {
        PiecePath(cells: piece.cells, headDirection: piece.headDirection,
                  cellSize: cellSize, spacing: spacing)
            .stroke(color, style: StrokeStyle(lineWidth: max(1, cellSize * 0.10), lineCap: .round, lineJoin: .round))
            .frame(width: side, height: side, alignment: .topLeading)
            .offset(slide)
            .opacity(Double(1 - progress))
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) { progress = 1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { onDone() }
            }
    }

    private var slide: CGSize {
        let distance = side * progress
        let (dr, dc) = piece.headDirection.delta
        return CGSize(width: CGFloat(dc) * distance, height: CGFloat(dr) * distance)
    }
}

/// One snake piece as a single continuous rounded line through its cell centers,
/// ending in a chevron head.
struct PiecePath: Shape {
    let cells: [Position]
    let headDirection: Direction
    let cellSize: CGFloat
    let spacing: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !cells.isEmpty else { return path }
        let centers = cells.map(center)
        let (dr, dc) = headDirection.delta
        let ext = cellSize * 0.38
        let headPoint = CGPoint(
            x: centers[centers.count - 1].x + CGFloat(dc) * ext,
            y: centers[centers.count - 1].y + CGFloat(dr) * ext
        )

        path.move(to: centers[0])
        for point in centers.dropFirst() { path.addLine(to: point) }
        path.addLine(to: headPoint)

        let ux = CGFloat(dc), uy = CGFloat(dr)
        let hs = cellSize * 0.18
        let perpX = -uy, perpY = ux
        let baseX = headPoint.x - ux * hs, baseY = headPoint.y - uy * hs
        path.move(to: CGPoint(x: baseX + perpX * hs, y: baseY + perpY * hs))
        path.addLine(to: headPoint)
        path.addLine(to: CGPoint(x: baseX - perpX * hs, y: baseY - perpY * hs))
        return path
    }

    private func center(_ p: Position) -> CGPoint {
        CGPoint(
            x: CGFloat(p.col) * (cellSize + spacing) + cellSize / 2,
            y: CGFloat(p.row) * (cellSize + spacing) + cellSize / 2
        )
    }
}

/// Subtle graph-paper dots at cell corners behind the board.
private struct DotGrid: View {
    var cellSize: CGFloat
    var dotSize: CGFloat = 2
    var color: Color = Color.gray.opacity(0.22)

    var body: some View {
        Canvas { context, size in
            // Dots at cell centers — same lattice as PiecePath.center(), so paths snap to dots.
            let step = cellSize
            let offset = cellSize / 2
            var y: CGFloat = offset
            while y <= size.height - offset + 0.5 {
                var x: CGFloat = offset
                while x <= size.width - offset + 0.5 {
                    let rect = CGRect(x: x - dotSize / 2, y: y - dotSize / 2,
                                     width: dotSize, height: dotSize)
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                    x += step
                }
                y += step
            }
        }
    }
}
