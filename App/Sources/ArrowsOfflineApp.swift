import SwiftUI

@main
struct ArrowsOfflineApp: App {
    @AppStorage(SettingsKey.appearance) private var appearance = AppearanceOption.system.rawValue

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(AppearanceOption(rawValue: appearance)?.colorScheme)
        }
    }
}
