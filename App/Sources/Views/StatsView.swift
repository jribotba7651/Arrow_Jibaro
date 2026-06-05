import SwiftUI

struct StatsView: View {
    @State private var progress = GameProgress.initial
    private let store = ProgressStore()

    var body: some View {
        List {
            Section("Progress") {
                row("Current level", "\(progress.currentLevel)")
                row("Highest level", "\(progress.highestLevelReached)")
            }
            Section("Daily") {
                row("Current streak", "\(progress.dailyStreak)")
                row("Last completed", progress.lastDailyCompleted ?? "\u{2014}")
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { progress = store.load() }
    }

    private func row(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack { StatsView() }
}
