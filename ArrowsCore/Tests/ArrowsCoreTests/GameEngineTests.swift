import XCTest
@testable import ArrowsCore

final class GameEngineTests: XCTestCase {
    private func makeState(_ pieces: [Piece], size: Int, lives: Int = 3) -> GameState {
        GameState(board: Board(size: size, pieces: pieces), lives: lives, level: 1, seed: 0)
    }

    func testTapEscapesAndWins() {
        var state = makeState([TestBoards.piece(0, .right, head: (0, 1), length: 2)], size: 4)
        let outcome = GameEngine.tap(at: Position(row: 0, col: 0), in: &state) // tail cell
        XCTAssertEqual(outcome, .escaped(pieceID: 0))
        XCTAssertTrue(state.board.isCleared)
        XCTAssertEqual(state.status, .won)
    }

    func testTapBlockedLosesLife() {
        let a = TestBoards.piece(0, .right, head: (0, 1), length: 2)
        let b = TestBoards.piece(1, .right, head: (0, 3), length: 1)
        var state = makeState([a, b], size: 4)
        let outcome = GameEngine.tap(at: Position(row: 0, col: 1), in: &state) // head of a
        XCTAssertEqual(outcome, .blocked(pieceID: 0, by: 1))
        XCTAssertEqual(state.lives, 2)
        XCTAssertEqual(state.status, .playing)
    }

    func testTapEmptyCellIgnored() {
        var state = makeState([TestBoards.piece(0, .right, head: (0, 1), length: 1)], size: 4)
        XCTAssertEqual(GameEngine.tap(at: Position(row: 3, col: 3), in: &state), .ignored)
    }

    func testRunningOutOfLivesLoses() {
        let a = TestBoards.piece(0, .right, head: (0, 1), length: 2)
        let b = TestBoards.piece(1, .right, head: (0, 3), length: 1)
        var state = makeState([a, b], size: 4, lives: 1)
        _ = GameEngine.tap(at: Position(row: 0, col: 1), in: &state)
        XCTAssertEqual(state.status, .lost)
    }
}
