import XCTest
@testable import ArrowsCore

final class BoardTests: XCTestCase {
    func testOccupancyAndRemoval() {
        let piece = TestBoards.straight(0, .right, head: (0, 2), length: 3)
        var board = Board(size: 4, pieces: [piece])
        XCTAssertEqual(board.remaining, 1)
        XCTAssertEqual(board.piece(at: Position(row: 0, col: 0))?.id, 0)
        XCTAssertEqual(board.piece(at: Position(row: 0, col: 2))?.id, 0)
        XCTAssertNil(board.piece(at: Position(row: 1, col: 0)))
        board.remove(0)
        XCTAssertTrue(board.isCleared)
    }

    func testHeadAndTail() {
        let piece = TestBoards.straight(0, .up, head: (1, 2), length: 2)
        XCTAssertEqual(piece.head, Position(row: 1, col: 2))
        XCTAssertEqual(piece.tail, Position(row: 2, col: 2))
    }

    func testBentPieceOccupiesAllCells() {
        // An L-shaped piece: (2,0) -> (1,0) -> (1,1), head up-then-right.
        let cells = [Position(row: 2, col: 0), Position(row: 1, col: 0), Position(row: 1, col: 1)]
        let piece = Piece(id: 0, cells: cells, headDirection: .right)
        let board = Board(size: 3, pieces: [piece])
        XCTAssertEqual(board.piece(at: Position(row: 1, col: 1))?.id, 0)
        XCTAssertEqual(board.piece(at: Position(row: 2, col: 0))?.id, 0)
        XCTAssertEqual(piece.head, Position(row: 1, col: 1))
    }
}
