import XCTest
@testable import ArrowsCore

final class BoardTests: XCTestCase {
    func testEmptyBoardIsCleared() {
        let board = Board(size: 3)
        XCTAssertEqual(board.remaining, 0)
        XCTAssertTrue(board.isCleared)
    }

    func testRemainingCountsArrows() {
        let board = BoardFactory.makeBoard([
            ">.<",
            ".^.",
            "v.>",
        ])
        XCTAssertEqual(board.remaining, 5)
        XCTAssertFalse(board.isCleared)
    }

    func testInBounds() {
        let board = Board(size: 2)
        XCTAssertTrue(board.inBounds(Position(row: 0, col: 0)))
        XCTAssertTrue(board.inBounds(Position(row: 1, col: 1)))
        XCTAssertFalse(board.inBounds(Position(row: -1, col: 0)))
        XCTAssertFalse(board.inBounds(Position(row: 0, col: 2)))
    }

    func testArrowAtOutOfBoundsIsNil() {
        let board = BoardFactory.makeBoard([">.", ".<"])
        XCTAssertNil(board.arrow(at: Position(row: 5, col: 5)))
        XCTAssertNotNil(board.arrow(at: Position(row: 0, col: 0)))
    }

    func testRemoveArrowReturnsAndClears() {
        var board = BoardFactory.makeBoard([">.", ".<"])
        let removed = board.removeArrow(at: Position(row: 0, col: 0))
        XCTAssertEqual(removed?.direction, .right)
        XCTAssertNil(board.arrow(at: Position(row: 0, col: 0)))
        XCTAssertEqual(board.remaining, 1)
        // Removing an empty cell is a no-op returning nil.
        XCTAssertNil(board.removeArrow(at: Position(row: 0, col: 0)))
    }

    func testOccupiedPositionsAreRowMajor() {
        let board = BoardFactory.makeBoard([
            ">.<",
            "...",
            "v..",
        ])
        XCTAssertEqual(board.occupiedPositions, [
            Position(row: 0, col: 0),
            Position(row: 0, col: 2),
            Position(row: 2, col: 0),
        ])
    }
}
