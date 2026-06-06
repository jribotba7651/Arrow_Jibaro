@testable import ArrowsCore

/// Test helpers for building piece-based boards.
enum TestBoards {
    /// A straight piece: `length` cells ending at `head`, pointing `direction`.
    static func straight(_ id: Int, _ direction: Direction, head: (Int, Int), length: Int) -> Piece {
        let h = Position(row: head.0, col: head.1)
        let (dr, dc) = direction.delta
        var cells: [Position] = []
        for i in 0..<length {
            cells.append(Position(row: h.row - dr * i, col: h.col - dc * i))
        }
        return Piece(id: id, cells: cells.reversed(), headDirection: direction)
    }
}
