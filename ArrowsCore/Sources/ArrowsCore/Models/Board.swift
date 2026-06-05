import Foundation

/// An NxN grid packed with straight `Piece`s. Cells reference the piece that
/// occupies them; empty cells are gaps.
public struct Board: Hashable, Codable {
    public let size: Int
    public private(set) var pieces: [Int: Piece]
    public private(set) var occupancy: [[Int?]]

    /// Builds a board from non-overlapping, in-bounds pieces.
    public init(size: Int, pieces: [Piece]) {
        precondition(size > 0, "Board size must be positive")
        var occ = [[Int?]](repeating: [Int?](repeating: nil, count: size), count: size)
        var dict: [Int: Piece] = [:]
        for piece in pieces {
            for cell in piece.cells {
                precondition(
                    cell.row >= 0 && cell.row < size && cell.col >= 0 && cell.col < size,
                    "piece \(piece.id) is out of bounds at \(cell)"
                )
                precondition(occ[cell.row][cell.col] == nil, "pieces overlap at \(cell)")
                occ[cell.row][cell.col] = piece.id
            }
            dict[piece.id] = piece
        }
        self.size = size
        self.pieces = dict
        self.occupancy = occ
    }

    public var remaining: Int { pieces.count }
    public var isCleared: Bool { pieces.isEmpty }

    public func inBounds(_ row: Int, _ col: Int) -> Bool {
        row >= 0 && row < size && col >= 0 && col < size
    }

    public func pieceID(atRow row: Int, col: Int) -> Int? {
        inBounds(row, col) ? occupancy[row][col] : nil
    }

    public func piece(at position: Position) -> Piece? {
        guard let id = pieceID(atRow: position.row, col: position.col) else { return nil }
        return pieces[id]
    }

    /// Removes a piece and clears its cells.
    @discardableResult
    public mutating func remove(_ id: Int) -> Bool {
        guard let piece = pieces[id] else { return false }
        for cell in piece.cells { occupancy[cell.row][cell.col] = nil }
        pieces[id] = nil
        return true
    }

    /// Piece ids in a stable (ascending) order.
    public var pieceIDsInOrder: [Int] { pieces.keys.sorted() }
}
