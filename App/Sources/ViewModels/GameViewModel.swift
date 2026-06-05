import Foundation
import Combine
import ArrowsCore

/// Orchestrates a single game session on top of the pure `ArrowsCore` engine.
/// The view layer only observes this; all rules live in the core.
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState

    private let startingLives: Int
    private let progressStore: ProgressStoring?

    init(
        level: Int = 1,
        seed: UInt64? = nil,
        lives: Int = 3,
        progressStore: ProgressStoring? = nil
    ) {
        self.startingLives = lives
        self.progressStore = progressStore
        let resolvedSeed = seed ?? Self.defaultSeed(forLevel: level)
        let generated = LevelGenerator.generate(level: level, seed: resolvedSeed)
        self.state = GameState(
            board: generated.board,
            lives: lives,
            level: generated.level,
            seed: generated.seed
        )
        persist()
    }

    var board: Board { state.board }
    var lives: Int { state.lives }
    var level: Int { state.level }
    var status: GameState.Status { state.status }

    /// Applies a tap on a cell. No-op on empty cells or once the game is over.
    @discardableResult
    func tap(_ position: Position) -> TapOutcome {
        objectWillChange.send()
        let outcome = GameEngine.tap(position, in: &state)
        if state.status == .won {
            persist()
        }
        return outcome
    }

    /// Replays the current level from scratch (same seed, fresh lives).
    func restart() {
        let generated = LevelGenerator.generate(level: state.level, seed: state.seed)
        state = GameState(
            board: generated.board,
            lives: startingLives,
            level: state.level,
            seed: generated.seed
        )
    }

    /// Advances to the next level with its default seed.
    func advanceToNextLevel() {
        let next = state.level + 1
        let generated = LevelGenerator.generate(level: next, seed: Self.defaultSeed(forLevel: next))
        state = GameState(
            board: generated.board,
            lives: startingLives,
            level: next,
            seed: generated.seed
        )
        persist()
    }

    private func persist() {
        guard let progressStore else { return }
        var progress = progressStore.load()
        progress.currentLevel = state.level
        progress.highestLevelReached = max(progress.highestLevelReached, state.level)
        progressStore.save(progress)
    }

    private static func defaultSeed(forLevel level: Int) -> UInt64 {
        UInt64(level) &* 0x1_0000 &+ 0x9E3
    }
}
