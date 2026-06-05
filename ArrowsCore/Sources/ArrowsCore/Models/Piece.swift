import Foundation

/// A straight segment of `length` cells with an arrow head at one end. The head
/// is the front cell in `direction`; the body extends backwards from it.
public struct Piece: Identifiable, Hashable, Codable {
    public let id: Int
    public let direction: Direction
    public let head: Position
    public let length: Int

    public init(id: Int, direction: Direction, head: Position, length: Int) {
        precondition(length >= 1, "piece length must be >= 1")
        self.id = id
        self.direction = direction
        self.head = head
        self.length = length
    }

    /// Cells occupied, from the head backwards along the opposite of `direction`.
    public var cells: [Position] {
        let (dr, dc) = direction.delta
        return (0..<length).map { i in
            Position(row: head.row - dr * i, col: head.col - dc * i)
        }
    }

    /// The back cell of the segment.
    public var tail: Position {
        let (dr, dc) = direction.delta
        return Position(row: head.row - dr * (length - 1), col: head.col - dc * (length - 1))
    }
}
