import Foundation

/// Greedy, row-major solver. It repeatedly fires the first arrow (scanning in
/// row-major order) whose path escapes the board, until the board is cleared or
/// no arrow can escape. Because it uses the same `ShotResolver` as the live
/// game, a board it can clear is solvable exactly the way the game plays.
public enum GreedySolver {
    /// True if the greedy strategy fully clears the board.
    public static func isSolvable(_ board: Board) -> Bool {
        solution(for: board) != nil
    }

    /// The sequence of taps that clears the board greedily, or `nil` if the
    /// greedy strategy gets stuck before clearing it.
    public static func solution(for board: Board) -> [Position]? {
        var work = board
        var moves: [Position] = []
        while !work.isCleared {
            guard let position = firstEscapable(in: work) else { return nil }
            work.removeArrow(at: position)
            moves.append(position)
        }
        return moves
    }

    /// The first occupied position (row-major) whose arrow has a clear path off
    /// the board.
    static func firstEscapable(in board: Board) -> Position? {
        for position in board.occupiedPositions
        where ShotResolver.hasClearPath(on: board, at: position) {
            return position
        }
        return nil
    }
}
