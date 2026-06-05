import XCTest
@testable import ArrowsCore

final class BoardTests: XCTestCase {
    func testOccupancyAndRemoval() {
        let piece = TestBoards.piece(0, .right, head: (0, 2), length: 3) // (0,2),(0,1),(0,0)
        var board = Board(size: 4, pieces: [piece])
        XCTAssertEqual(board.remaining, 1)
        XCTAssertEqual(board.piece(at: Position(row: 0, col: 0))?.id, 0)
        XCTAssertEqual(board.piece(at: Position(row: 0, col: 2))?.id, 0)
        XCTAssertNil(board.piece(at: Position(row: 1, col: 0)))
        board.remove(0)
        XCTAssertTrue(board.isCleared)
        XCTAssertNil(board.piece(at: Position(row: 0, col: 0)))
    }

    func testPieceCellsAndTail() {
        let piece = TestBoards.piece(0, .up, head: (1, 2), length: 2) // (1,2),(2,2)
        XCTAssertEqual(piece.cells, [Position(row: 1, col: 2), Position(row: 2, col: 2)])
        XCTAssertEqual(piece.tail, Position(row: 2, col: 2))
    }
}
