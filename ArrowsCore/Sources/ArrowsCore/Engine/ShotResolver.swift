import Foundation

/// The outcome of firing the arrow at a given origin cell.
public enum ShotResult: Equatable {
    /// The path to the border was clear; the arrow leaves the board.
    case escaped
    /// The arrow collided with another arrow at `blocker`; it stays put.
    case blocked(by: Position)
}

/// Pure, side-effect-free resolution of an arrow's trajectory. This is the
/// single source of truth shared by the game loop and the level solver, so a
/// generated level is always solvable exactly the way it plays.
public enum ShotResolver {
    /// Resolves the trajectory of the arrow at `origin` without mutating the
    /// board.
    /// - Returns: `.escaped` if the straight path to the edge is clear,
    ///   `.blocked` if another arrow is in the way, or `nil` if there is no
    ///   arrow at `origin`.
    public static func resolve(on board: Board, firingAt origin: Position) -> ShotResult? {
        guard let arrow = board.arrow(at: origin) else { return nil }
        let (dr, dc) = arrow.direction.delta
        var r = origin.row + dr
        var c = origin.col + dc
        while board.inBounds(row: r, col: c) {
            if board.cells[r][c] != nil {
                return .blocked(by: Position(row: r, col: c))
            }
            r += dr
            c += dc
        }
        return .escaped
    }

    /// Whether the arrow at `origin` currently has a clear path off the board.
    public static func hasClearPath(on board: Board, at origin: Position) -> Bool {
        resolve(on: board, firingAt: origin) == .escaped
    }
}
