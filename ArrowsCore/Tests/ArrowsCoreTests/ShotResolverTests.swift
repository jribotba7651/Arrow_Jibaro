import XCTest
@testable import ArrowsCore

final class ShotResolverTests: XCTestCase {
    func testEscapesWhenFrontClear() {
        let piece = TestBoards.straight(0, .right, head: (0, 1), length: 2)
        let board = Board(size: 4, pieces: [piece])
        XCTAssertEqual(ShotResolver.resolve(on: board, pieceID: 0), .escaped)
    }

    func testBlockedByPieceInFront() {
        let a = TestBoards.straight(0, .right, head: (0, 1), length: 2)
        let b = TestBoards.straight(1, .right, head: (0, 3), length: 1)
        let board = Board(size: 4, pieces: [a, b])
        XCTAssertEqual(ShotResolver.resolve(on: board, pieceID: 0), .blocked(by: 1))
    }

    func testVerticalEscapes() {
        let piece = TestBoards.straight(0, .up, head: (1, 2), length: 2)
        let board = Board(size: 4, pieces: [piece])
        XCTAssertEqual(ShotResolver.resolve(on: board, pieceID: 0), .escaped)
    }

    func testInvalidIDReturnsNil() {
        let board = Board(size: 3, pieces: [])
        XCTAssertNil(ShotResolver.resolve(on: board, pieceID: 5))
    }
}
