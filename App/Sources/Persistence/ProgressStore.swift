import Foundation

/// Persisted player progress. Intentionally tiny and Codable — stored locally,
/// never synced.
struct GameProgress: Codable, Equatable {
    var currentLevel: Int
    var highestLevelReached: Int

    static let initial = GameProgress(currentLevel: 1, highestLevelReached: 1)
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
