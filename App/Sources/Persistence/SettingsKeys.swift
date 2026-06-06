import Foundation

/// UserDefaults keys shared between `@AppStorage` views and the feedback
/// helpers. Keeping them in one place avoids stringly-typed drift.
enum SettingsKey {
    static let sound = "settings.sound"
    static let haptics = "settings.haptics"
    static let appearance = "settings.appearance"
    static let skin = "settings.skin"
}
