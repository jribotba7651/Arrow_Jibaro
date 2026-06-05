import SwiftUI
import ArrowsCore

/// Renders the board as connected line-art arrows — one per `Piece`, spanning
/// its cells — on a dotted background. Reports taps via `onTap`, slides escaped
/// pieces off the board, and flashes collisions.
struct BoardView: View {
    let board: Board
    var hint: Position? = nil
    let onTap: (Position) -> TapOutcome

    @State private var collisionPieceID: Int?
    @State private var shake: CGFloat = 0
    @State private var ghosts: [Ghost] = []

    private let spacing: CGFloat = 2

    var body: some View {
        GeometryReader { geo in
            let side = max(1, min(geo.size.width, geo.size.height))
            let count = CGFloat(board.size)
            let cellSize = max(1, (side - spacing * (count - 1)) / count)
            ZStack(alignment: .topLeading) {
                ForEach(board.pieceIDsInOrder, id: \.self) { id in
                    if let piece = board.pieces[id] {
                        let rect = pieceRect(piece, cellSize: cellSize)
                        PieceArrowView(direction: piece.direction, color: color(for: piece))
                            .frame(width: rect.width, height: rect.height)
                            .contentShape(Rectangle())
                            .onTapGesture { handleTap(piece) }
                            .offset(x: rect.minX, y: rect.minY)
                    }
                }
                ForEach(ghosts) { ghost in
                    let rect = pieceRect(ghost.piece, cellSize: cellSize)
                    EscapingPieceView(direction: ghost.piece.direction, travel: side) {
                        ghosts.removeAll { $0.id == ghost.id }
                    }
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.minX, y: rect.minY)
                    .allowsHitTesting(false)
                }
            }
            .frame(width: side, height: side, alignment: .topLeading)
            .background(DotGrid(spacing: max(12, cellSize / 2)))
            .modifier(ShakeEffect(animatableData: shake))
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func origin(_ index: Int, _ cellSize: CGFloat) -> CGFloat {
        CGFloat(index) * (cellSize + spacing)
    }

    private func pieceRect(_ piece: Piece, cellSize: CGFloat) -> CGRect {
        let rows = piece.cells.map { $0.row }
        let cols = piece.cells.map { $0.col }
        let minRow = rows.min() ?? 0, maxRow = rows.max() ?? 0
        let minCol = cols.min() ?? 0, maxCol = cols.max() ?? 0
        let width = CGFloat(maxCol - minCol + 1) * cellSize + CGFloat(maxCol - minCol) * spacing
        let height = CGFloat(maxRow - minRow + 1) * cellSize + CGFloat(maxRow - minRow) * spacing
        return CGRect(x: origin(minCol, cellSize), y: origin(minRow, cellSize), width: width, height: height)
    }

    private var hintPieceID: Int? {
        guard let hint else { return nil }
        return board.piece(at: hint)?.id
    }

    private func color(for piece: Piece) -> Color? {
        if piece.id == collisionPieceID { return .red }
        if piece.id == hintPieceID { return .green }
        return nil
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

/// A piece sliding off the board in its direction, then fading out.
private struct EscapingPieceView: View {
    let direction: Direction
    let travel: CGFloat
    let onDone: () -> Void

    @State private var progress: CGFloat = 0

    var body: some View {
        PieceArrowView(direction: direction)
            .offset(slide)
            .opacity(Double(1 - progress))
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) { progress = 1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { onDone() }
            }
    }

    private var slide: CGSize {
        let distance = travel * progress
        let (dr, dc) = direction.delta
        return CGSize(width: CGFloat(dc) * distance, height: CGFloat(dr) * distance)
    }
}

/// A connected arrow for a single straight piece: a shaft along the long axis of
/// its rect with a chevron head, stroked with round caps/joins.
struct PieceArrowShape: Shape {
    let direction: Direction

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let thickness = min(rect.width, rect.height)
        let margin = thickness * 0.30
        let cx = rect.midX, cy = rect.midY
        var head = CGPoint.zero
        var tail = CGPoint.zero
        switch direction {
        case .right: tail = CGPoint(x: rect.minX + margin, y: cy); head = CGPoint(x: rect.maxX - margin, y: cy)
        case .left:  tail = CGPoint(x: rect.maxX - margin, y: cy); head = CGPoint(x: rect.minX + margin, y: cy)
        case .down:  tail = CGPoint(x: cx, y: rect.minY + margin); head = CGPoint(x: cx, y: rect.maxY - margin)
        case .up:    tail = CGPoint(x: cx, y: rect.maxY - margin); head = CGPoint(x: cx, y: rect.minY + margin)
        }

        path.move(to: tail)
        path.addLine(to: head)

        let (dr, dc) = direction.delta
        let ux = CGFloat(dc), uy = CGFloat(dr)
        let hs = thickness * 0.34
        let perpX = -uy, perpY = ux
        let baseX = head.x - ux * hs, baseY = head.y - uy * hs
        path.move(to: CGPoint(x: baseX + perpX * hs, y: baseY + perpY * hs))
        path.addLine(to: head)
        path.addLine(to: CGPoint(x: baseX - perpX * hs, y: baseY - perpY * hs))
        return path
    }
}

/// The piece arrow in the selected skin color (or an override for feedback).
struct PieceArrowView: View {
    let direction: Direction
    var color: Color? = nil
    @AppStorage(SettingsKey.skin) private var skinRaw = ArrowSkin.classic.rawValue

    private var skin: ArrowSkin { ArrowSkin(rawValue: skinRaw) ?? .classic }

    var body: some View {
        GeometryReader { geo in
            PieceArrowShape(direction: direction).stroke(
                color ?? skin.tint,
                style: StrokeStyle(
                    lineWidth: min(geo.size.width, geo.size.height) * 0.16,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}

/// Subtle graph-paper dots behind the board.
private struct DotGrid: View {
    var spacing: CGFloat
    var dotSize: CGFloat = 2
    var color: Color = Color.gray.opacity(0.22)

    var body: some View {
        Canvas { context, size in
            var y = spacing / 2
            while y < size.height {
                var x = spacing / 2
                while x < size.width {
                    let rect = CGRect(
                        x: x - dotSize / 2,
                        y: y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                    x += spacing
                }
                y += spacing
            }
        }
    }
}
