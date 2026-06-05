@testable import ArrowsCore

/// Test helpers for building piece-based boards.
enum TestBoards {
    static func piece(_ id: Int, _ direction: Direction, head: (Int, Int), length: Int) -> Piece {
        Piece(id: id, direction: direction, head: Position(row: head.0, col: head.1), length: length)
    }
}
