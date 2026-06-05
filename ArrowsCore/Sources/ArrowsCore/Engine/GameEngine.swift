import Foundation

/// The result of applying a single player tap.
public enum TapOutcome: Equatable {
    /// The tapped arrow escaped and was removed from the board.
    case escaped(from: Position)
    /// The tapped arrow was blocked; a life was lost. The arrow stays put.
    case blocked(from: Position, by: Position)
    /// The tap had no effect (empty cell, or the game was already over).
    case ignored
}

/// Applies player moves to a `GameState`. Stateless: all state lives in the
/// `inout GameState`, keeping the engine trivially testable.
public enum GameEngine {
    /// Applies a tap on `position`, mutating the board, lives and status.
    @discardableResult
    public static func tap(_ position: Position, in state: inout GameState) -> TapOutcome {
        guard state.status == .playing else { return .ignored }
        guard let result = ShotResolver.resolve(on: state.board, firingAt: position) else {
            return .ignored
        }
        switch result {
        case .escaped:
            state.board.removeArrow(at: position)
            state.refreshStatus()
            return .escaped(from: position)
        case .blocked(let blocker):
            state.lives -= 1
            state.refreshStatus()
            return .blocked(from: position, by: blocker)
        }
    }
}
