import Foundation
import Combine
import ArrowsCore

/// Orchestrates a single game session on top of the pure `ArrowsCore` engine.
/// The view layer only observes this; all rules live in the core.
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState

    private let startingLives: Int
    private let progressStore: ProgressStoring?
    private let dailyToday: UInt64?
    private let dailyYesterday: UInt64?

    init(
        level: Int = 1,
        seed: UInt64? = nil,
        lives: Int = 3,
        progressStore: ProgressStoring? = nil,
        dailyToday: UInt64? = nil,
        dailyYesterday: UInt64? = nil
    ) {
        self.startingLives = lives
        self.progressStore = progressStore
        self.dailyToday = dailyToday
        self.dailyYesterday = dailyYesterday
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

    /// Today's daily challenge, wired to update the daily streak on completion.
    static func daily(
        level: Int = 4,
        store: ProgressStoring? = nil,
        date: Date = Date(),
        calendar: Calendar = .current
    ) -> GameViewModel {
        let today = DailyChallenge.seed(for: date, calendar: calendar)
        let previous = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        let yesterday = DailyChallenge.seed(for: previous, calendar: calendar)
        return GameViewModel(
            level: level,
            seed: today,
            progressStore: store,
            dailyToday: today,
            dailyYesterday: yesterday
        )
    }

    var board: Board { state.board }
    var lives: Int { state.lives }
    var level: Int { state.level }
    var status: GameState.Status { state.status }
    var isDaily: Bool { dailyToday != nil }

    /// Applies a tap on a cell. No-op on empty cells or once the game is over.
    @discardableResult
    func tap(_ position: Position) -> TapOutcome {
        let outcome = GameEngine.tap(at: position, in: &state)
        if state.status == .won { persist() }
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

    /// Head cell of the next piece the greedy solver would clear (for the hint).
    func hint() -> Position? {
        guard let id = GreedySolver.solution(for: board)?.first else { return nil }
        return board.pieces[id]?.head
    }

    private func persist() {
        guard let progressStore else { return }
        if let today = dailyToday {
            guard state.status == .won else { return }
            var progress = progressStore.load()
            let todayKey = String(today)
            guard progress.lastDailyCompleted != todayKey else { return }
            if let yesterday = dailyYesterday,
               progress.lastDailyCompleted == String(yesterday) {
                progress.dailyStreak += 1
            } else {
                progress.dailyStreak = 1
            }
            progress.lastDailyCompleted = todayKey
            progressStore.save(progress)
        } else {
            var progress = progressStore.load()
            progress.currentLevel = state.level
            progress.highestLevelReached = max(progress.highestLevelReached, state.level)
            progressStore.save(progress)
        }
    }

    private static func defaultSeed(forLevel level: Int) -> UInt64 {
        UInt64(level) &* 0x1_0000 &+ 0x9E3
    }
}
