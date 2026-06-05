import Foundation

/// A generated, ready-to-play level together with the seed that produced it, so
/// it can be reproduced exactly later.
public struct GeneratedLevel: Hashable {
    public let board: Board
    public let seed: UInt64
    public let level: Int

    public init(board: Board, seed: UInt64, level: Int) {
        self.board = board
        self.seed = seed
        self.level = level
    }
}

/// Builds solvable levels deterministically from a seed. Never returns an
/// unsolvable board: it accepts a candidate only when it is both non-trivial
/// and greedy-solvable, and falls back to a guaranteed-solvable arrangement if
/// no random candidate qualifies within `maxAttempts`.
public enum LevelGenerator {
    /// Grid side length for a level: level 1 -> 3x3, level 2 -> 4x4, ...
    public static func size(forLevel level: Int) -> Int {
        max(1, level) + 2
    }

    /// Generates the level. Starting from `seed`, it tries seed, seed+1, ...
    /// until a candidate is accepted, returning the seed that actually produced
    /// the board so callers can persist and reproduce it.
    public static func generate(
        level: Int,
        seed: UInt64,
        maxAttempts: Int = 2000
    ) -> GeneratedLevel {
        let side = size(forLevel: level)
        var attempt: UInt64 = 0
        while attempt < UInt64(maxAttempts) {
            let candidateSeed = seed &+ attempt
            let board = fill(size: side, seed: candidateSeed)
            if isAcceptable(board) {
                return GeneratedLevel(board: board, seed: candidateSeed, level: level)
            }
            attempt += 1
        }
        // Extremely unlikely; keeps generation total and reproducible.
        return GeneratedLevel(board: solvableFallback(size: side), seed: seed, level: level)
    }

    /// Fills every cell with a seeded random direction.
    static func fill(size: Int, seed: UInt64) -> Board {
        var rng = SeededGenerator(seed: seed)
        var cells = [[Arrow?]](repeating: [Arrow?](repeating: nil, count: size), count: size)
        var nextID = 0
        for r in 0..<size {
            for c in 0..<size {
                let direction = Direction.allCases.randomElement(using: &rng)!
                cells[r][c] = Arrow(id: nextID, direction: direction)
                nextID += 1
            }
        }
        return Board(size: size, cells: cells)
    }

    /// A candidate is acceptable when it is solvable by the greedy strategy and
    /// not trivial (at most half of the arrows can already escape).
    static func isAcceptable(_ board: Board) -> Bool {
        let positions = board.occupiedPositions
        guard !positions.isEmpty else { return false }
        let escapable = positions.filter {
            ShotResolver.hasClearPath(on: board, at: $0)
        }.count
        guard escapable * 2 <= positions.count else { return false }
        return GreedySolver.isSolvable(board)
    }

    /// A board where every arrow points right. The rightmost arrow of each row
    /// always has a clear path, so the greedy solver clears it row by row.
    static func solvableFallback(size: Int) -> Board {
        var cells = [[Arrow?]](repeating: [Arrow?](repeating: nil, count: size), count: size)
        var nextID = 0
        for r in 0..<size {
            for c in 0..<size {
                cells[r][c] = Arrow(id: nextID, direction: .right)
                nextID += 1
            }
        }
        return Board(size: size, cells: cells)
    }
}
