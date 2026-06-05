import Foundation

/// An NxN grid of optional arrows. The board is value-typed so the engine can
/// reason about it without side effects; mutation goes through explicit methods.
public struct Board: Hashable, Codable {
    public let size: Int
    public private(set) var cells: [[Arrow?]]

    /// Creates a board from an explicit `size x size` matrix of cells.
    public init(size: Int, cells: [[Arrow?]]) {
        precondition(size > 0, "Board size must be positive")
        precondition(
            cells.count == size && cells.allSatisfy { $0.count == size },
            "cells must be a size x size matrix"
        )
        self.size = size
        self.cells = cells
    }

    /// Creates an empty board of the given size.
    public init(size: Int) {
        let row = [Arrow?](repeating: nil, count: size)
        self.init(size: size, cells: [[Arrow?]](repeating: row, count: size))
    }

    /// Number of arrows still on the board.
    public var remaining: Int {
        cells.reduce(0) { $0 + $1.compactMap { $0 }.count }
    }

    /// True when no arrows remain.
    public var isCleared: Bool { remaining == 0 }

    public func inBounds(row: Int, col: Int) -> Bool {
        row >= 0 && row < size && col >= 0 && col < size
    }

    public func inBounds(_ p: Position) -> Bool {
        inBounds(row: p.row, col: p.col)
    }

    /// The arrow at `p`, or nil if the cell is empty or out of bounds.
    public func arrow(at p: Position) -> Arrow? {
        guard inBounds(p) else { return nil }
        return cells[p.row][p.col]
    }

    /// Removes and returns the arrow at `p`, if any.
    @discardableResult
    public mutating func removeArrow(at p: Position) -> Arrow? {
        guard inBounds(p), let arrow = cells[p.row][p.col] else { return nil }
        cells[p.row][p.col] = nil
        return arrow
    }

    /// Places (or clears) an arrow at `p`.
    public mutating func setArrow(_ arrow: Arrow?, at p: Position) {
        precondition(inBounds(p), "position \(p) out of bounds for size \(size)")
        cells[p.row][p.col] = arrow
    }

    /// All occupied positions, scanned in row-major order. Matches the order the
    /// greedy solver/level generator rely on.
    public var occupiedPositions: [Position] {
        var result: [Position] = []
        for r in 0..<size {
            for c in 0..<size where cells[r][c] != nil {
                result.append(Position(row: r, col: c))
            }
        }
        return result
    }
}
