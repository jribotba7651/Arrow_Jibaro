import XCTest
@testable import ArrowsCore

final class LevelGeneratorTests: XCTestCase {
    func testSizeMapping() {
        XCTAssertEqual(LevelGenerator.size(forLevel: 1), 3)
        XCTAssertEqual(LevelGenerator.size(forLevel: 5), 7)
    }

    func testGenerationIsDeterministic() {
        let a = LevelGenerator.generate(level: 4, seed: 123)
        let b = LevelGenerator.generate(level: 4, seed: 123)
        XCTAssertEqual(a.board, b.board)
    }

    func testGeneratedLevelsAreSolvable() {
        for level in 1...6 {
            let generated = LevelGenerator.generate(level: level, seed: UInt64(level) * 97)
            XCTAssertEqual(generated.board.size, level + 2)
            XCTAssertGreaterThan(generated.board.remaining, 0)
            XCTAssertTrue(
                GreedySolver.isSolvable(generated.board),
                "level \(level) should be solvable"
            )
        }
    }

    func testDailySeedIsStable() {
        XCTAssertEqual(DailyChallenge.seed(year: 2026, month: 6, day: 5), 20_260_605)
    }
}
