import Foundation

/// A single arrow occupying a cell, pointing in one of four directions.
public struct Arrow: Identifiable, Hashable, Codable {
    public let id: Int
    public var direction: Direction

    public init(id: Int, direction: Direction) {
        self.id = id
        self.direction = direction
    }
}
