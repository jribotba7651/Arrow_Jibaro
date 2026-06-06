import Foundation

/// A connected path of cells (tail -> head) that may bend at corners, with an
/// arrow head at the last cell. Cells are orthogonally adjacent in sequence.
public struct Piece: Identifiable, Hashable, Codable {
    public let id: Int
    public let cells: [Position]
    public let headDirection: Direction

    public init(id: Int, cells: [Position], headDirection: Direction) {
        precondition(!cells.isEmpty, "piece must have at least one cell")
        self.id = id
        self.cells = cells
        self.headDirection = headDirection
    }

    /// The leading cell (where the arrow head is).
    public var head: Position { cells[cells.count - 1] }

    /// The trailing cell.
    public var tail: Position { cells[0] }

    public var length: Int { cells.count }
}
