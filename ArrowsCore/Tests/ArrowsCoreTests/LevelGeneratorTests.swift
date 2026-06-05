import XCTest
@testable import ArrowsCore

final class LevelGeneratorTests: XCTestCase {
    func testSizeMapping() {
        XCTAssertEqual(LevelGenerator.size(forLevel: 1), 3)
        XCTAssertEqual(LevelGenerator.size(forLevel: 2), 4)
        XCTAssertEqual(LevelGenerator.size(forLevel: 5), 7)
    }

    func testGenerationIsDeterministic() {
        let a = LevelGenerator.generate(level: 3, seed: 12345)
        let b = LevelGenerator.generate(level: 3, seed: 12345)
        XCTAssertEqual(a.board, b.board)
        XCTAssertEqual(a.seed, b.seed)
    }

    func testGeneratedLevelIsSolvable() {
        for level in 1...6 {
            let generated = LevelGenerator.generate(level: level, seed: UInt64(level) &* 101)
            XCTAssertEqual(generated.board.size, level + 2)
            XCTAssertTrue(
                GreedySolver.isSolvable(generated.board),
                "level \(level) should be solvable"
            )
        }
    }

    func testGeneratedLevelRespectsDifficultyCap() {
        let generated = LevelGenerator.generate(level: 4, seed: 999)
        let positions = generated.board.occupiedPositions
        let escapable = positions.filter {
            ShotResolver.hasClearPath(on: generated.board, at: $0)
        }.count
        XCTAssertLessThanOrEqual(escapable * 2, positions.count)
    }

    func testReturnedSeedReproducesBoard() {
        let generated = LevelGenerator.generate(level: 3, seed: 5000)
        // Regenerating from the *returned* seed yields the same board on attempt 0.
        let reproduced = LevelGenerator.generate(level: 3, seed: generated.seed)
        XCTAssertEqual(reproduced.board, generated.board)
    }

    func testDailySeedIsStableAndDateDependent() {
        XCTAssertEqual(DailyChallenge.seed(year: 2026, month: 6, day: 5), 20_260_605)
        XCTAssertNotEqual(
            DailyChallenge.seed(year: 2026, month: 6, day: 5),
            DailyChallenge.seed(year: 2026, month: 6, day: 6)
        )
    }
}
