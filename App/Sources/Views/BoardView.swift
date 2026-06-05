import SwiftUI
import ArrowsCore

/// Renders the NxN grid and reports taps back by position. An optional cell can
/// be highlighted (red for a collision, green for a hint).
struct BoardView: View {
    let board: Board
    var highlight: Position? = nil
    var highlightColor: Color = .red
    let onTap: (Position) -> Void

    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<board.size, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<board.size, id: \.self) { col in
                        let position = Position(row: row, col: col)
                        CellView(
                            arrow: board.arrow(at: position),
                            isHighlighted: position == highlight,
                            highlightColor: highlightColor
                        ) {
                            onTap(position)
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct CellView: View {
    let arrow: Arrow?
    var isHighlighted: Bool = false
    var highlightColor: Color = .red
    let onTap: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(fillColor)
            if isHighlighted {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(highlightColor, lineWidth: 3)
            }
            if let arrow {
                ArrowView(direction: arrow.direction)
                    .padding(8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture {
            if arrow != nil { onTap() }
        }
    }

    private var fillColor: Color {
        if isHighlighted { return highlightColor.opacity(0.25) }
        return arrow == nil ? Color.gray.opacity(0.12) : Color.accentColor.opacity(0.18)
    }
}
