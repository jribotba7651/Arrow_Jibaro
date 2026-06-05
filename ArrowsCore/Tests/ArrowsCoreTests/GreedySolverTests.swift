import XCTest
@testable import ArrowsCore

final class GreedySolverTests: XCTestCase {
    func testSolvableChain() {
        let back = TestBoards.straight(0, .right, head: (0, 1), length: 1)
        let front = TestBoards.straight(1, .right, head: (0, 3), length: 1)
        let board = Board(size: 4, pieces: [back, front])
        XCTAssertTrue(GreedySolver.isSolvable(board))
        XCTAssertEqual(GreedySolver.solution(for: board), [1, 0])
    }

    func testStuck() {
        let a = TestBoards.straight(0, .right, head: (0, 0), length: 1)
        let b = TestBoards.straight(1, .left, head: (0, 1), length: 1)
        let board = Board(size: 2, pieces: [a, b])
        XCTAssertFalse(GreedySolver.isSolvable(board))
    }
}
