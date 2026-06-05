import SwiftUI
import ArrowsCore

/// Renders the NxN grid and reports taps back by position.
struct BoardView: View {
    let board: Board
    let onTap: (Position) -> Void

    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<board.size, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<board.size, id: \.self) { col in
                        let position = Position(row: row, col: col)
                        CellView(arrow: board.arrow(at: position)) {
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
    let onTap: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(arrow == nil ? Color.gray.opacity(0.12) : Color.accentColor.opacity(0.18))
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
}
