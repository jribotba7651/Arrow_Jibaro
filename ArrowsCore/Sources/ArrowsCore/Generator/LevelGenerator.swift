import Foundation

/// A generated, ready-to-play level together with the seed that produced it.
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

/// Builds dense, always-solvable boards of bending snake pieces. Generation is
/// in reverse: each new piece is placed only when its head's forward path to the
/// board edge is clear of all already-placed pieces, guaranteeing greedy
/// solvability (reverse-placement order always works).
public enum LevelGenerator {
    /// Grid side length: level 1 -> 3x3, level 2 -> 4x4, ...
    public static func size(forLevel level: Int) -> Int {
        max(1, level) + 2
    }

    public static func generate(level: Int, seed: UInt64) -> GeneratedLevel {
        let n = size(forLevel: level)
        var rng = SeededGenerator(seed: seed)
        let board = build(size: n, rng: &rng)
        return GeneratedLevel(board: board, seed: seed, level: level)
    }

    // Internal entry point kept for any test/preview callers.
    static func build(size n: Int, maxLength: Int, rng: inout SeededGenerator) -> Board {
        build(size: n, rng: &rng)
    }

    static func build(size n: Int, rng: inout SeededGenerator) -> Board {
        var occupied = [[Bool]](repeating: [Bool](repeating: false, count: n), count: n)
        var placed: [Piece] = []
        var nextID = 0

        // Two-pass strategy: long pieces first (≥ n/3 cells), then fill gaps.
        let longMin  = max(3, n / 3)
        let shortMin = 2

        for minLen in [longMin, shortMin] {
            var improved = true
            while improved {
                improved = false
                var empties = emptyCells(occupied, n)
                if empties.isEmpty { break }
                for i in stride(from: empties.count - 1, through: 1, by: -1) {
                    let j = Int(rng.next() % UInt64(i + 1))
                    empties.swapAt(i, j)
                }
                for anchor in empties {
                    guard !occupied[anchor.row][anchor.col] else { continue }
                    if let piece = randomWalkPiece(start: anchor, occupied: occupied, size: n,
                                                   maxLength: n, minLength: minLen,
                                                   id: nextID, rng: &rng) {
                        for cell in piece.cells { occupied[cell.row][cell.col] = true }
                        placed.append(piece)
                        nextID += 1
                        improved = true
                    }
                }
            }
            if emptyCells(occupied, n).isEmpty { break }
        }

        // Fallback: fill any remaining isolated cells as pairs then singles.
        for r in 0..<n {
            for c in 0..<n where !occupied[r][c] {
                let a = Position(row: r, col: c)
                var filledPair = false
                for dir in Direction.allCases {
                    let (dr, dc) = dir.delta
                    let nb = Position(row: r + dr, col: c + dc)
                    guard inBounds(nb.row, nb.col, n), !occupied[nb.row][nb.col] else { continue }
                    guard frontClear(head: nb, dir: dir, occupied: occupied, size: n,
                                     exclude: [a, nb]) else { continue }
                    placed.append(Piece(id: nextID, cells: [a, nb], headDirection: dir))
                    occupied[r][c] = true
                    occupied[nb.row][nb.col] = true
                    nextID += 1
                    filledPair = true
                    break
                }
                if filledPair { continue }
                for dir in Direction.allCases
                where frontClear(head: a, dir: dir, occupied: occupied, size: n, exclude: [a]) {
                    placed.append(Piece(id: nextID, cells: [a], headDirection: dir))
                    occupied[r][c] = true
                    nextID += 1
                    break
                }
            }
        }

        return Board(size: n, pieces: placed)
    }

    private static func emptyCells(_ occupied: [[Bool]], _ n: Int) -> [Position] {
        var result: [Position] = []
        for r in 0..<n {
            for c in 0..<n where !occupied[r][c] { result.append(Position(row: r, col: c)) }
        }
        return result
    }

    /// Self-avoiding random walk with a strong turn bias (70% prefer perpendicular
    /// moves) so pieces snake/wind through the grid, creating the maze look.
    /// Truncates from the tail until the head has a clear escape path; returns nil
    /// if the surviving path is shorter than `minLength`.
    private static func randomWalkPiece(start: Position, occupied: [[Bool]], size n: Int,
                                        maxLength: Int, minLength: Int, id: Int,
                                        rng: inout SeededGenerator) -> Piece? {
        // Bias the target toward the upper half of the length range.
        let lo = minLength
        let hi = maxLength
        let targetLength = lo + Int(rng.next() % UInt64(max(1, hi - lo + 1)))

        var path = [start]
        var inPath: Set<Position> = [start]
        var previous: Direction?

        while path.count < targetLength {
            let current = path.last!
            var turns: [Direction] = []    // perpendicular to `previous`
            var straight: [Direction] = [] // same as `previous` (or any dir if first step)

            for dir in Direction.allCases {
                if let prev = previous, dir == prev.opposite { continue }
                let (dr, dc) = dir.delta
                let next = Position(row: current.row + dr, col: current.col + dc)
                guard inBounds(next.row, next.col, n),
                      !occupied[next.row][next.col],
                      !inPath.contains(next) else { continue }
                if previous == nil || dir == previous {
                    straight.append(dir)
                } else {
                    turns.append(dir)
                }
            }

            if turns.isEmpty && straight.isEmpty { break }

            // 70% prefer a turn when one is available — creates winding pieces.
            let pool: [Direction]
            if turns.isEmpty {
                pool = straight
            } else if straight.isEmpty || Int(rng.next() % 10) < 7 {
                pool = turns
            } else {
                pool = straight
            }

            let chosen = pool[Int(rng.next() % UInt64(pool.count))]
            let (dr, dc) = chosen.delta
            let next = Position(row: current.row + dr, col: current.col + dc)
            path.append(next)
            inPath.insert(next)
            previous = chosen
        }

        // Truncate from tail until head direction is frontClear.
        while path.count >= minLength {
            let head = path.last!
            let exclude = Set(path)
            if path.count >= 2 {
                let headDir = direction(from: path[path.count - 2], to: head)
                if frontClear(head: head, dir: headDir, occupied: occupied, size: n,
                               exclude: exclude) {
                    return Piece(id: id, cells: path, headDirection: headDir)
                }
            } else {
                for dir in Direction.allCases
                where frontClear(head: head, dir: dir, occupied: occupied, size: n,
                                 exclude: exclude) {
                    return Piece(id: id, cells: path, headDirection: dir)
                }
            }
            path.removeLast()
        }
        return nil
    }

    private static func direction(from a: Position, to b: Position) -> Direction {
        if b.row < a.row { return .up }
        if b.row > a.row { return .down }
        if b.col < a.col { return .left }
        return .right
    }

    private static func frontClear(head: Position, dir: Direction, occupied: [[Bool]],
                                   size n: Int, exclude: Set<Position>) -> Bool {
        let (dr, dc) = dir.delta
        var r = head.row + dr, c = head.col + dc
        while inBounds(r, c, n) {
            if occupied[r][c] { return false }
            if exclude.contains(Position(row: r, col: c)) { return false }
            r += dr; c += dc
        }
        return true
    }

    private static func inBounds(_ r: Int, _ c: Int, _ n: Int) -> Bool {
        r >= 0 && r < n && c >= 0 && c < n
    }
}
