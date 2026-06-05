import SwiftUI
import ArrowsCore

struct HomeView: View {
    @State private var progress = GameProgress.initial
    @State private var newGameLevel = 1
    private let store = ProgressStore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Text("\u{1F3F9}")
                    .font(.system(size: 84))
                Text("Arrows Offline")
                    .font(.largeTitle.bold())
                Text("Tap an arrow to fire it. Clear the board.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                if progress.dailyStreak > 0 {
                    Label("\(progress.dailyStreak)-day streak", systemImage: "flame.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                }
                Spacer()
                VStack(spacing: 12) {
                    if progress.currentLevel > 1 {
                        NavigationLink {
                            GameView(viewModel: GameViewModel(
                                level: progress.currentLevel,
                                progressStore: store
                            ))
                        } label: {
                            primaryLabel("Continue \u{00B7} Level \(progress.currentLevel)")
                        }
                    }
                    HStack(spacing: 8) {
                        NavigationLink {
                            GameView(viewModel: GameViewModel(level: newGameLevel,
                                                              progressStore: store))
                        } label: {
                            secondaryLabel("Level \(newGameLevel)")
                        }
                        Stepper("", value: $newGameLevel, in: 1...20)
                            .labelsHidden()
                            .fixedSize()
                    }
                    NavigationLink {
                        GameView(viewModel: .daily(store: store))
                    } label: {
                        secondaryLabel("Daily challenge")
                    }
                }
                .padding(.horizontal, 40)
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink { SettingsView() } label: { Image(systemName: "gearshape") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink { CollectionView() } label: { Image(systemName: "paintpalette") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink { StatsView() } label: { Image(systemName: "chart.bar") }
                }
            }
            .onAppear { progress = store.load() }
        }
    }

    private func primaryLabel(_ title: String) -> some View {
        Text(title)
            .font(.title2.bold())
            .frame(maxWidth: .infinity)
            .padding()
            .background(.tint, in: RoundedRectangle(cornerRadius: 16))
            .foregroundStyle(.white)
    }

    private func secondaryLabel(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16).stroke(.tint, lineWidth: 2)
            )
            .foregroundStyle(.tint)
    }
}

#Preview {
    HomeView()
}
