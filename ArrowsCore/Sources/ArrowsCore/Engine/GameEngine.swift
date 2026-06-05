import Foundation

/// The result of applying a single tap.
public enum TapOutcome: Equatable {
    /// The tapped piece escaped and was removed.
    case escaped(pieceID: Int)
    /// The tapped piece was blocked by `by`; a life was lost.
    case blocked(pieceID: Int, by: Int)
    /// The tap had no effect (empty cell, or the game was already over).
    case ignored
}

/// Applies player taps to a `GameState`. Stateless and trivially testable.
public enum GameEngine {
    /// Applies a tap on `position`, resolving the piece that occupies that cell.
    @discardableResult
    public static func tap(at position: Position, in state: inout GameState) -> TapOutcome {
        guard state.status == .playing else { return .ignored }
        guard let piece = state.board.piece(at: position) else { return .ignored }
        guard let result = ShotResolver.resolve(on: state.board, pieceID: piece.id) else {
            return .ignored
        }
        switch result {
        case .escaped:
            state.board.remove(piece.id)
            state.refreshStatus()
            return .escaped(pieceID: piece.id)
        case .blocked(let blocker):
            state.lives -= 1
            state.refreshStatus()
            return .blocked(pieceID: piece.id, by: blocker)
        }
    }
}
