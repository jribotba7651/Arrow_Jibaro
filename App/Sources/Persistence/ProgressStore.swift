import Foundation

/// Persisted player progress. Intentionally tiny and Codable — stored locally,
/// never synced. New fields decode with defaults so older saves keep working.
struct GameProgress: Codable, Equatable {
    var currentLevel: Int
    var highestLevelReached: Int
    var lastDailyCompleted: String?
    var dailyStreak: Int

    static let initial = GameProgress(
        currentLevel: 1,
        highestLevelReached: 1,
        lastDailyCompleted: nil,
        dailyStreak: 0
    )

    init(
        currentLevel: Int,
        highestLevelReached: Int,
        lastDailyCompleted: String? = nil,
        dailyStreak: Int = 0
    ) {
        self.currentLevel = currentLevel
        self.highestLevelReached = highestLevelReached
        self.lastDailyCompleted = lastDailyCompleted
        self.dailyStreak = dailyStreak
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let current = try container.decodeIfPresent(Int.self, forKey: .currentLevel) ?? 1
        currentLevel = current
        highestLevelReached =
            try container.decodeIfPresent(Int.self, forKey: .highestLevelReached) ?? current
        lastDailyCompleted =
            try container.decodeIfPresent(String.self, forKey: .lastDailyCompleted)
        dailyStreak = try container.decodeIfPresent(Int.self, forKey: .dailyStreak) ?? 0
    }
}

/// Abstraction so the view model can be tested with an in-memory double.
protocol ProgressStoring {
    func load() -> GameProgress
    func save(_ progress: GameProgress)
}

/// `UserDefaults`-backed progress storage. Simple and fully offline; can be
/// migrated to SwiftData later if the app targets iOS 17+.
final class ProgressStore: ProgressStoring {
    private let defaults: UserDefaults
    private let key = "arrows.progress.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> GameProgress {
        guard
            let data = defaults.data(forKey: key),
            let progress = try? JSONDecoder().decode(GameProgress.self, from: data)
        else {
            return .initial
        }
        return progress
    }

    func save(_ progress: GameProgress) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: key)
    }
}
