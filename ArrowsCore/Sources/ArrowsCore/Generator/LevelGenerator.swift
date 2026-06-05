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
/// in reverse: each new piece (a self-avoiding random walk) is placed only if
/// its head's forward path is clear of already-placed pieces and of its own
/// body, which guarantees the forward solve order exists.
public enum LevelGenerator {
    /// Grid side length: level 1 -> 3x3, level 2 -> 4x4, ...
    public static func size(forLevel level: Int) -> Int {
        max(1, level) + 2
    }

    public static func generate(level: Int, seed: UInt64) -> GeneratedLevel {
        let n = size(forLevel: level)
        var rng = SeededGenerator(seed: seed)
        // Short pieces (2–3 cells) pack far more densely than long ones.
        let board = build(size: n, maxLength: min(3, n), rng: &rng)
        return GeneratedLevel(board: board, seed: seed, level: level)
    }

    static func build(size n: Int, maxLength: Int, rng: inout SeededGenerator) -> Board {
        var occupied = [[Bool]](repeating: [Bool](repeating: false, count: n), count: n)
        var placed: [Piece] = []
        var nextID = 0
        var stalls = 0
        let stallLimit = n * n * 8

        while stalls < stallLimit {
            let empties = emptyCells(occupied, n)
            if empties.isEmpty { break }
            let anchor = empties[Int(rng.next() % UInt64(empties.count))]
            // After many stalls fall back to length-2 pieces to break deadlocks.
            let tryMax = stalls > n * n ? 2 : maxLength
            if let piece = randomWalkPiece(start: anchor, occupied: occupied, size: n,
                                           maxLength: tryMax, id: nextID, rng: &rng) {
                for cell in piece.cells { occupied[cell.row][cell.col] = true }
                placed.append(piece)
                nextID += 1
                stalls = 0
            } else {
                stalls += 1
            }
        }

        // Fill leftover adjacent empty pairs as 2-cell pieces.
        for r in 0..<n {
            for c in 0..<n where !occupied[r][c] {
                let a = Position(row: r, col: c)
                var filled = false
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
                    filled = true
                    break
                }
                if filled { continue }
                // Fallback: single-cell piece if a clear direction exists.
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
            for c in 0..<n where !occupied[r][c] {
                result.append(Position(row: r, col: c))
            }
        }
        return result
    }

    /// A self-avoiding random walk starting at `start`, turning at corners, with
    /// a head whose forward path is clear of placed pieces and of its own body.
    private static func randomWalkPiece(start: Position, occupied: [[Bool]], size n: Int,
                                        maxLength: Int, id: Int,
                                        rng: inout SeededGenerator) -> Piece? {
        let targetLength = 2 + Int(rng.next() % UInt64(max(1, maxLength - 1)))
        var path = [start]
        var inPath: Set<Position> = [start]
        var previous: Direction?

        while path.count < targetLength {
            let current = path[path.count - 1]
            let startDir = Int(rng.next() % 4)
            var moved = false
            for offset in 0..<4 {
                let dir = Direction.allCases[(startDir + offset) % 4]
                if let previous, dir == previous.opposite { continue }
                let (dr, dc) = dir.delta
                let next = Position(row: current.row + dr, col: current.col + dc)
                if inBounds(next.row, next.col, n) && !occupied[next.row][next.col]
                    && !inPath.contains(next) {
                    path.append(next)
                    inPath.insert(next)
                    previous = dir
                    moved = true
                    break
                }
            }
            if !moved { break }
        }

        let head = path[path.count - 1]
        let headDirection: Direction
        if path.count >= 2 {
            headDirection = direction(from: path[path.count - 2], to: head)
        } else {
            guard let dir = Direction.allCases.first(where: {
                frontClear(head: head, dir: $0, occupied: occupied, size: n, exclude: inPath)
            }) else { return nil }
            headDirection = dir
        }
        guard frontClear(head: head, dir: headDirection, occupied: occupied, size: n, exclude: inPath) else {
            return nil
        }
        return Piece(id: id, cells: path, headDirection: headDirection)
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
