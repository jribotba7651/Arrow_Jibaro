import XCTest
@testable import ArrowsCore

final class GameEngineTests: XCTestCase {
    private func makeState(
        _ rows: [String],
        lives: Int = 3
    ) -> GameState {
        GameState(
            board: BoardFactory.makeBoard(rows),
            lives: lives,
            level: 1,
            seed: 0
        )
    }

    func testTapClearPathRemovesArrow() {
        var state = makeState([
            ">..",
            "...",
            "...",
        ])
        let outcome = GameEngine.tap(Position(row: 0, col: 0), in: &state)
        XCTAssertEqual(outcome, .escaped(from: Position(row: 0, col: 0)))
        XCTAssertNil(state.board.arrow(at: Position(row: 0, col: 0)))
        XCTAssertEqual(state.lives, 3)
    }

    func testTapBlockedLosesLifeAndKeepsArrow() {
        var state = makeState([
            ">.<",
            "...",
            "...",
        ])
        let outcome = GameEngine.tap(Position(row: 0, col: 0), in: &state)
        XCTAssertEqual(
            outcome,
            .blocked(from: Position(row: 0, col: 0), by: Position(row: 0, col: 2))
        )
        XCTAssertEqual(state.lives, 2)
        XCTAssertNotNil(state.board.arrow(at: Position(row: 0, col: 0)))
        XCTAssertEqual(state.status, .playing)
    }

    func testClearingLastArrowWins() {
        var state = makeState([
            ">.",
            "..",
        ])
        _ = GameEngine.tap(Position(row: 0, col: 0), in: &state)
        XCTAssertTrue(state.board.isCleared)
        XCTAssertEqual(state.status, .won)
    }

    func testRunningOutOfLivesLoses() {
        var state = makeState([
            ">.<",
            "...",
            "...",
        ], lives: 1)
        let outcome = GameEngine.tap(Position(row: 0, col: 0), in: &state)
        XCTAssertEqual(
            outcome,
            .blocked(from: Position(row: 0, col: 0), by: Position(row: 0, col: 2))
        )
        XCTAssertEqual(state.lives, 0)
        XCTAssertEqual(state.status, .lost)
    }

    func testTapEmptyCellIsIgnored() {
        var state = makeState([">..", "...", "..."])
        let outcome = GameEngine.tap(Position(row: 2, col: 2), in: &state)
        XCTAssertEqual(outcome, .ignored)
        XCTAssertEqual(state.lives, 3)
    }

    func testTapAfterGameOverIsIgnored() {
        var state = makeState([
            ">.",
            "..",
        ])
        _ = GameEngine.tap(Position(row: 0, col: 0), in: &state) // wins
        XCTAssertEqual(state.status, .won)
        let outcome = GameEngine.tap(Position(row: 0, col: 0), in: &state)
        XCTAssertEqual(outcome, .ignored)
    }

    func testWinTakesPrecedenceWhenLastMoveAlsoEmptiesBoard() {
        // Clearing the final arrow wins even though it is the last one.
        var state = makeState([
            "..>",
            "...",
            "...",
        ], lives: 1)
        let outcome = GameEngine.tap(Position(row: 0, col: 2), in: &state)
        XCTAssertEqual(outcome, .escaped(from: Position(row: 0, col: 2)))
        XCTAssertEqual(state.status, .won)
    }
}
