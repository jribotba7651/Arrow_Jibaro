import Foundation

/// Board fill density by difficulty tier.
public enum Difficulty: Int, CaseIterable {
    case easy, medium, hard, nightmare

    var densityRange: ClosedRange<Double> {
        switch self {
        case .easy:      return 0.55...0.68
        case .medium:    return 0.72...0.82
        case .hard:      return 0.82...0.90
        case .nightmare: return 0.88...0.94
        }
    }
}

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

/// Builds dense, always-solvable boards of many short bending pieces.
///
/// Placement is in reverse: a piece is placed only when its head's forward
/// lane to the board edge is clear of already-placed pieces and its own body.
/// This guarantees greedy solvability.
///
/// Three passes, all capped at the target density:
///  Pass 1 — shuffled sweeps of empty cells; each cell tried as anchor of a
///           short (2–3 cell) self-avoiding random walk with 70 % turn-bias.
///           Sweeps repeat until a full pass makes no progress.
///  Pass 2 — deterministic straight-segment fill; sweeps cells in row-major
///           order, placing the longest straight run with a clear head lane.
///           Repeats until no progress.
///  Pass 3 — single-cell fallback for any remaining isolated cells.
public enum LevelGenerator {
    public static func size(forLevel level: Int) -> Int {
        max(1, level) + 2
    }

    public static func generate(level: Int, seed: UInt64,
                                difficulty: Difficulty = .medium) -> GeneratedLevel {
        let n = size(forLevel: level)
        var rng = SeededGenerator(seed: seed)
        let target = pickTarget(difficulty: difficulty, rng: &rng)
        let board = build(size: n, maxLength: 3, targetDensity: target, rng: &rng)
        return GeneratedLevel(board: board, seed: seed, level: level)
    }

    // Kept for test call-site compatibility.
    static func build(size n: Int, maxLength: Int, rng: inout SeededGenerator) -> Board {
        build(size: n, maxLength: maxLength, targetDensity: 0.75, rng: &rng)
    }

    static func build(size n: Int, maxLength: Int, targetDensity: Double,
                      rng: inout SeededGenerator) -> Board {
        let cap = max(1, Int((Double(n * n) * targetDensity).rounded()))
        var occupied = [[Bool]](repeating: [Bool](repeating: false, count: n), count: n)
        var placed: [Piece] = []
        var nextID = 0
        var filled = 0

        // Pass 1 — random-walk sweeps (seeded, turn-biased).
        var improved = true
        while improved && filled < cap {
            improved = false
            var empties = emptyCells(occupied, n)
            if empties.isEmpty { break }
            fisherYates(&empties, rng: &rng)
            for anchor in empties {
                guard !occupied[anchor.row][anchor.col], filled < cap else { continue }
                if let piece = randomWalkPiece(start: anchor, occupied: occupied,
                                               size: n, maxLength: maxLength,
                                               id: nextID, rng: &rng) {
                    for cell in piece.cells { occupied[cell.row][cell.col] = true }
                    filled += piece.cells.count
                    placed.append(piece)
                    nextID += 1
                    improved = true
                }
            }
        }

        // Pass 2 — deterministic straight-segment fill for remaining gaps.
        improved = true
        while improved && filled < cap {
            improved = false
            for r in 0..<n {
                for c in 0..<n where !occupied[r][c] && filled < cap {
                    if let piece = straightPiece(at: Position(row: r, col: c),
                                                 occupied: occupied, size: n,
                                                 maxLength: maxLength, id: nextID) {
                        for cell in piece.cells { occupied[cell.row][cell.col] = true }
                        filled += piece.cells.count
                        placed.append(piece)
                        nextID += 1
                        improved = true
                    }
                }
            }
        }

        // Single-cell pieces are intentionally not placed — they render as
        // isolated arrow glyphs. Empty cells are left blank instead.

        return Board(size: n, pieces: placed)
    }

    // MARK: - Private helpers

    private static func pickTarget(difficulty: Difficulty,
                                   rng: inout SeededGenerator) -> Double {
        let r = difficulty.densityRange
        let t = Double(rng.next() % 1000) / 1000.0
        return r.lowerBound + t * (r.upperBound - r.lowerBound)
    }

    private static func emptyCells(_ occupied: [[Bool]], _ n: Int) -> [Position] {
        var result: [Position] = []
        for r in 0..<n {
            for c in 0..<n where !occupied[r][c] { result.append(Position(row: r, col: c)) }
        }
        return result
    }

    private static func fisherYates(_ arr: inout [Position], rng: inout SeededGenerator) {
        for i in stride(from: arr.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            arr.swapAt(i, j)
        }
    }

    /// Self-avoiding random walk, 70 % turn-bias, 2–`maxLength` cells.
    /// Trims tail until head has a clear escape lane.
    private static func randomWalkPiece(start: Position, occupied: [[Bool]], size n: Int,
                                        maxLength: Int, id: Int,
                                        rng: inout SeededGenerator) -> Piece? {
        let lo = max(2, maxLength / 2)
        let targetLen = lo + Int(rng.next() % UInt64(max(1, maxLength - lo + 1)))

        var path = [start]
        var inPath: Set<Position> = [start]
        var previous: Direction?

        while path.count < targetLen {
            let cur = path.last!
            var turns: [Direction] = []
            var straight: [Direction] = []
            for dir in Direction.allCases {
                if let prev = previous, dir == prev.opposite { continue }
                let (dr, dc) = dir.delta
                let next = Position(row: cur.row + dr, col: cur.col + dc)
                guard inBounds(next.row, next.col, n),
                      !occupied[next.row][next.col],
                      !inPath.contains(next) else { continue }
                if previous == nil || dir == previous { straight.append(dir) }
                else { turns.append(dir) }
            }
            if turns.isEmpty && straight.isEmpty { break }
            let pool: [Direction]
            if turns.isEmpty { pool = straight }
            else if straight.isEmpty || Int(rng.next() % 10) < 7 { pool = turns }
            else { pool = straight }
            let chosen = pool[Int(rng.next() % UInt64(pool.count))]
            let (dr, dc) = chosen.delta
            path.append(Position(row: cur.row + dr, col: cur.col + dc))
            inPath.insert(path.last!)
            previous = chosen
        }

        while path.count >= 2 {
            let head = path.last!
            let headDir = direction(from: path[path.count - 2], to: head)
            if frontClear(head: head, dir: headDir, occupied: occupied,
                          size: n, exclude: Set(path)) {
                return Piece(id: id, cells: path, headDirection: headDir)
            }
            path.removeLast()
        }
        // Single-cell pieces are never returned — they look like isolated glyphs.
        return nil
    }

    /// Straight run of at least 2 cells from `cell` in the first direction
    /// that gives a clear head escape. Deterministic (no RNG).
    private static func straightPiece(at cell: Position, occupied: [[Bool]], size n: Int,
                                      maxLength: Int, id: Int) -> Piece? {
        for dir in Direction.allCases {
            let (dr, dc) = dir.delta
            var run = 1
            var r = cell.row + dr, c = cell.col + dc
            while run < maxLength && inBounds(r, c, n) && !occupied[r][c] {
                run += 1; r += dr; c += dc
            }
            guard run >= 2 else { continue }  // never place 1-cell pieces
            let cells = (0..<run).map {
                Position(row: cell.row + dr * $0, col: cell.col + dc * $0)
            }
            let head = cells[cells.count - 1]
            if frontClear(head: head, dir: dir, occupied: occupied,
                          size: n, exclude: Set(cells)) {
                return Piece(id: id, cells: cells, headDirection: dir)
            }
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
