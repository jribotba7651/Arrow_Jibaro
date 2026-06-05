import XCTest
@testable import ArrowsCore

final class GreedySolverTests: XCTestCase {
    func testAllRightBoardIsSolvable() {
        let board = BoardFactory.makeBoard([
            ">>>",
            ">>>",
            ">>>",
        ])
        XCTAssertTrue(GreedySolver.isSolvable(board))
        XCTAssertEqual(GreedySolver.solution(for: board)?.count, 9)
    }

    func testArrowsFacingEachOtherAreStuck() {
        // Neither arrow can escape: each is blocked by the other.
        let board = BoardFactory.makeBoard([
            "><",
            "..",
        ])
        XCTAssertFalse(GreedySolver.isSolvable(board))
        XCTAssertNil(GreedySolver.solution(for: board))
    }

    func testSolutionClearsTheBoard() {
        let board = BoardFactory.makeBoard([
            ">.<",
            "...",
            "v.^",
        ])
        guard let moves = GreedySolver.solution(for: board) else {
            return XCTFail("expected a solution")
        }
        // Replaying the solution must empty the board.
        var work = board
        for move in moves {
            XCTAssertTrue(ShotResolver.hasClearPath(on: work, at: move))
            work.removeArrow(at: move)
        }
        XCTAssertTrue(work.isCleared)
    }

    func testFirstEscapableIsRowMajor() {
        let board = BoardFactory.makeBoard([
            "v.>",
            "...",
            "...",
        ])
        // Both arrows can escape; row-major picks (0,0) before (0,2).
        XCTAssertEqual(GreedySolver.firstEscapable(in: board), Position(row: 0, col: 0))
    }
}
