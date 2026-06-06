import Foundation

/// The four directions an arrow can point/fire in.
public enum Direction: String, CaseIterable, Codable, Hashable {
    case up, down, left, right

    /// Row/column step applied each time an arrow advances one cell.
    public var delta: (dr: Int, dc: Int) {
        switch self {
        case .up:    return (-1, 0)
        case .down:  return ( 1, 0)
        case .left:  return ( 0, -1)
        case .right: return ( 0,  1)
        }
    }

    /// The direction pointing the opposite way.
    public var opposite: Direction {
        switch self {
        case .up:    return .down
        case .down:  return .up
        case .left:  return .right
        case .right: return .left
        }
    }
}
