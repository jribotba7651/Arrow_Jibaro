import Foundation

/// A cell coordinate on the board.
public struct Position: Hashable, Codable, CustomStringConvertible {
    public let row: Int
    public let col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }

    public var description: String { "(\(row), \(col))" }
}
