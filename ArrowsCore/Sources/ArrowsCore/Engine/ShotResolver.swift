import Foundation

/// The outcome of firing a piece.
public enum ShotResult: Equatable {
    /// The forward path from the head to the border is clear; the piece leaves.
    case escaped
    /// Another piece (`by`) blocks the forward path; the piece stays put.
    case blocked(by: Int)
}

/// Pure resolution of a piece's slide, shared by the game loop and the solver.
public enum ShotResolver {
    /// Resolves the slide of `pieceID` along its head direction without mutating
    /// the board. Returns nil if there is no such piece.
    public static func resolve(on board: Board, pieceID: Int) -> ShotResult? {
        guard let piece = board.pieces[pieceID] else { return nil }
        let (dr, dc) = piece.headDirection.delta
        var r = piece.head.row + dr
        var c = piece.head.col + dc
        while board.inBounds(r, c) {
            if let blocker = board.occupancy[r][c] {
                return .blocked(by: blocker)
            }
            r += dr
            c += dc
        }
        return .escaped
    }

    /// Whether `pieceID` currently has a clear path off the board.
    public static func canEscape(_ board: Board, pieceID: Int) -> Bool {
        resolve(on: board, pieceID: pieceID) == .escaped
    }
}
