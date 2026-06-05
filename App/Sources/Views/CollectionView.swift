import SwiftUI

struct CollectionView: View {
    @AppStorage(SettingsKey.skin) private var selected = ArrowSkin.classic.rawValue
    @State private var progress = GameProgress.initial
    private let store = ProgressStore()

    private let columns = [GridItem(.adaptive(minimum: 130), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(ArrowSkin.allCases) { skin in
                    let unlocked = progress.highestLevelReached >= skin.unlockLevel
                    SkinTile(
                        skin: skin,
                        isSelected: skin.rawValue == selected,
                        isUnlocked: unlocked
                    ) {
                        if unlocked { selected = skin.rawValue }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Collection")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { progress = store.load() }
    }
}

private struct SkinTile: View {
    let skin: ArrowSkin
    let isSelected: Bool
    let isUnlocked: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.12))
                if isUnlocked {
                    ArrowGlyph(color: skin.tint)
                        .padding(30)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 110)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 3)
            )
            Text(skin.displayName)
                .font(.subheadline.bold())
            Text(statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    private var statusText: String {
        guard isUnlocked else { return "Unlocks at level \(skin.unlockLevel)" }
        return isSelected ? "Selected" : "Tap to use"
    }
}

#Preview {
    NavigationStack { CollectionView() }
}
