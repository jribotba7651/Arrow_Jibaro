import XCTest
@testable import ArrowsCore

final class ShotResolverTests: XCTestCase {
    func testArrowWithClearPathEscapes() {
        // A right-pointing arrow alone on its row escapes.
        let board = BoardFactory.makeBoard([
            ">..",
            "...",
            "...",
        ])
        XCTAssertEqual(
            ShotResolver.resolve(on: board, firingAt: Position(row: 0, col: 0)),
            .escaped
        )
    }

    func testArrowBlockedByAnotherArrow() {
        // Right-pointing at (0,0) hits the arrow at (0,2).
        let board = BoardFactory.makeBoard([
            ">.<",
            "...",
            "...",
        ])
        XCTAssertEqual(
            ShotResolver.resolve(on: board, firingAt: Position(row: 0, col: 0)),
            .blocked(by: Position(row: 0, col: 2))
        )
    }

    func testBlockerIsTheFirstArrowInPath() {
        // Right-pointing at (0,0) should report (0,1), not (0,2).
        let board = BoardFactory.makeBoard([
            ">^^",
            "...",
            "...",
        ])
        XCTAssertEqual(
            ShotResolver.resolve(on: board, firingAt: Position(row: 0, col: 0)),
            .blocked(by: Position(row: 0, col: 1))
        )
    }

    func testEachDirectionEscapesFromCenter() {
        // A single arrow in the center always has a clear path, any direction.
        for dir in Direction.allCases {
            var board = Board(size: 3)
            board.setArrow(Arrow(id: 0, direction: dir), at: Position(row: 1, col: 1))
            XCTAssertTrue(
                ShotResolver.hasClearPath(on: board, at: Position(row: 1, col: 1)),
                "expected clear path for \(dir)"
            )
        }
    }

    func testUpwardArrowBlocked() {
        // Up-pointing at (2,0) hits the down-pointing arrow at (0,0).
        let board = BoardFactory.makeBoard([
            "v..",
            "...",
            "^..",
        ])
        XCTAssertEqual(
            ShotResolver.resolve(on: board, firingAt: Position(row: 2, col: 0)),
            .blocked(by: Position(row: 0, col: 0))
        )
    }

    func testResolveEmptyCellReturnsNil() {
        let board = BoardFactory.makeBoard([">..", "...", "..."])
        XCTAssertNil(ShotResolver.resolve(on: board, firingAt: Position(row: 1, col: 1)))
    }
}
