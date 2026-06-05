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

/// Builds dense, always-solvable boards of straight pieces. Generation is in
/// reverse: each new piece is placed only if its forward path is clear of the
/// pieces already on the board, which guarantees the forward solve order exists.
public enum LevelGenerator {
    /// Grid side length: level 1 -> 3x3, level 2 -> 4x4, ...
    public static func size(forLevel level: Int) -> Int {
        max(1, level) + 2
    }

    public static func generate(level: Int, seed: UInt64) -> GeneratedLevel {
        let n = size(forLevel: level)
        var rng = SeededGenerator(seed: seed)
        let board = build(size: n, maxLength: min(4, n), rng: &rng)
        return GeneratedLevel(board: board, seed: seed, level: level)
    }

    static func build(size n: Int, maxLength: Int, rng: inout SeededGenerator) -> Board {
        var occupied = [[Bool]](repeating: [Bool](repeating: false, count: n), count: n)
        var placed: [Piece] = []
        var nextID = 0
        var stalls = 0
        let stallLimit = n * n * 2

        while stalls < stallLimit {
            let empties = emptyCells(occupied, n)
            if empties.isEmpty { break }
            let anchor = empties[Int(rng.next() % UInt64(empties.count))]
            let start = Int(rng.next() % 4)
            var didPlace = false
            for offset in 0..<4 {
                let dir = Direction.allCases[(start + offset) % 4]
                if let piece = makePiece(anchor: anchor, dir: dir, occupied: occupied,
                                         size: n, maxLength: maxLength, id: nextID, rng: &rng) {
                    for cell in piece.cells { occupied[cell.row][cell.col] = true }
                    placed.append(piece)
                    nextID += 1
                    didPlace = true
                    break
                }
            }
            if didPlace { stalls = 0 } else { stalls += 1 }
        }

        // Fill leftover single cells where a length-1 piece has a clear forward path.
        for r in 0..<n {
            for c in 0..<n where !occupied[r][c] {
                for dir in Direction.allCases {
                    let head = Position(row: r, col: c)
                    if frontClear(head: head, dir: dir, occupied: occupied, size: n) {
                        placed.append(Piece(id: nextID, direction: dir, head: head, length: 1))
                        occupied[r][c] = true
                        nextID += 1
                        break
                    }
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

    /// Builds a straight piece through `anchor` along `dir`, with all cells empty
    /// and a forward path clear of placed pieces. Returns nil if it doesn't fit.
    private static func makePiece(anchor: Position, dir: Direction, occupied: [[Bool]],
                                  size n: Int, maxLength: Int, id: Int,
                                  rng: inout SeededGenerator) -> Piece? {
        let (dr, dc) = dir.delta
        var forward = 0
        var r = anchor.row + dr, c = anchor.col + dc
        while inBounds(r, c, n) && !occupied[r][c] { forward += 1; r += dr; c += dc }
        var backward = 0
        r = anchor.row - dr; c = anchor.col - dc
        while inBounds(r, c, n) && !occupied[r][c] { backward += 1; r -= dr; c -= dc }

        let maxRun = forward + backward + 1
        let limit = min(maxLength, maxRun)
        guard limit >= 1 else { return nil }
        let length = Int(rng.next() % UInt64(limit)) + 1

        let headForward = min(forward, length - 1)
        let tailBack = (length - 1) - headForward
        guard tailBack <= backward else { return nil }

        let head = Position(row: anchor.row + dr * headForward, col: anchor.col + dc * headForward)
        guard frontClear(head: head, dir: dir, occupied: occupied, size: n) else { return nil }

        let piece = Piece(id: id, direction: dir, head: head, length: length)
        for cell in piece.cells {
            guard inBounds(cell.row, cell.col, n) && !occupied[cell.row][cell.col] else { return nil }
        }
        return piece
    }

    private static func frontClear(head: Position, dir: Direction, occupied: [[Bool]], size n: Int) -> Bool {
        let (dr, dc) = dir.delta
        var r = head.row + dr, c = head.col + dc
        while inBounds(r, c, n) {
            if occupied[r][c] { return false }
            r += dr; c += dc
        }
        return true
    }

    private static func inBounds(_ r: Int, _ c: Int, _ n: Int) -> Bool {
        r >= 0 && r < n && c >= 0 && c < n
    }
}
