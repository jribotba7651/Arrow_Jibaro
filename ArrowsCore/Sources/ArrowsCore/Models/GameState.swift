import Foundation

/// The full state of a single game/level in progress.
public struct GameState: Codable, Hashable {
    public enum Status: String, Codable, Hashable {
        case playing
        case won
        case lost
    }

    public var board: Board
    public var lives: Int
    public var level: Int
    public var seed: UInt64
    public private(set) var status: Status

    public init(
        board: Board,
        lives: Int,
        level: Int,
        seed: UInt64,
        status: Status = .playing
    ) {
        self.board = board
        self.lives = lives
        self.level = level
        self.seed = seed
        self.status = status
    }

    /// Recomputes `status` from the current board and lives. A cleared board
    /// wins even if lives are exhausted on the same move.
    public mutating func refreshStatus() {
        if board.isCleared {
            status = .won
        } else if lives <= 0 {
            status = .lost
        } else {
            status = .playing
        }
    }
}
