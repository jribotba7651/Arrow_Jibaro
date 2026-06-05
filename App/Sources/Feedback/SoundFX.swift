import AudioToolbox

/// System sound effects — no bundled audio assets, so the app stays tiny and
/// fully offline. Gated by the user's setting (default on).
enum SoundFX {
    private static var enabled: Bool {
        UserDefaults.standard.object(forKey: SettingsKey.sound) as? Bool ?? true
    }

    static func escaped() { play(1104) } // light "tock"
    static func blocked() { play(1053) } // negative beep
    static func won()     { play(1025) } // fanfare-ish

    private static func play(_ id: SystemSoundID) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(id)
    }
}
