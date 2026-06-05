import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKey.sound) private var sound = true
    @AppStorage(SettingsKey.haptics) private var haptics = true
    @AppStorage(SettingsKey.appearance) private var appearance = AppearanceOption.system.rawValue

    var body: some View {
        Form {
            Section("Feedback") {
                Toggle("Sound", isOn: $sound)
                Toggle("Haptics", isOn: $haptics)
            }
            Section("Appearance") {
                Picker("Theme", selection: $appearance) {
                    ForEach(AppearanceOption.allCases) { option in
                        Text(option.label).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("About") {
                Text("100% offline. No account, no ads, no network.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
