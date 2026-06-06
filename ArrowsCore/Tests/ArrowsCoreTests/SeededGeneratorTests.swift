import XCTest
@testable import ArrowsCore

final class SeededGeneratorTests: XCTestCase {
    func testSameSeedProducesSameSequence() {
        var a = SeededGenerator(seed: 42)
        var b = SeededGenerator(seed: 42)
        for _ in 0..<128 {
            XCTAssertEqual(a.next(), b.next())
        }
    }

    func testDifferentSeedsDiffer() {
        var a = SeededGenerator(seed: 1)
        var b = SeededGenerator(seed: 2)
        var sawDifference = false
        for _ in 0..<16 where a.next() != b.next() {
            sawDifference = true
        }
        XCTAssertTrue(sawDifference)
    }

    func testReproducibleRandomElement() {
        var a = SeededGenerator(seed: 7)
        var b = SeededGenerator(seed: 7)
        let options = Array(0..<10)
        for _ in 0..<50 {
            XCTAssertEqual(
                options.randomElement(using: &a),
                options.randomElement(using: &b)
            )
        }
    }
}
