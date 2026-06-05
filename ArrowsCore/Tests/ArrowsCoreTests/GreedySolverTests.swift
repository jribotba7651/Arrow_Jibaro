import XCTest
@testable import ArrowsCore

final class GreedySolverTests: XCTestCase {
    func testSolvableChain() {
        // The front piece escapes first, then the one behind it.
        let back = TestBoards.piece(0, .right, head: (0, 1), length: 1)
        let front = TestBoards.piece(1, .right, head: (0, 3), length: 1)
        let board = Board(size: 4, pieces: [back, front])
        XCTAssertTrue(GreedySolver.isSolvable(board))
        XCTAssertEqual(GreedySolver.solution(for: board), [1, 0])
    }

    func testStuck() {
        // Two length-1 pieces pointing into each other: neither can escape.
        let a = TestBoards.piece(0, .right, head: (0, 0), length: 1)
        let b = TestBoards.piece(1, .left, head: (0, 1), length: 1)
        let board = Board(size: 2, pieces: [a, b])
        XCTAssertFalse(GreedySolver.isSolvable(board))
    }
}
