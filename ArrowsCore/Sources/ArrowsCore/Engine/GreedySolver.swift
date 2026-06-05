import Foundation

/// Greedy solver. Removing a piece only frees cells (never blocks another), so
/// if any full solution exists, repeatedly removing any escapable piece clears
/// the board. Boards built by reverse placement are therefore always solvable.
public enum GreedySolver {
    public static func isSolvable(_ board: Board) -> Bool {
        solution(for: board) != nil
    }

    /// The sequence of piece ids to tap to clear the board, or nil if stuck.
    public static func solution(for board: Board) -> [Int]? {
        var work = board
        var moves: [Int] = []
        while !work.isCleared {
            guard let id = firstEscapable(in: work) else { return nil }
            work.remove(id)
            moves.append(id)
        }
        return moves
    }

    static func firstEscapable(in board: Board) -> Int? {
        for id in board.pieceIDsInOrder where ShotResolver.canEscape(board, pieceID: id) {
            return id
        }
        return nil
    }
}
