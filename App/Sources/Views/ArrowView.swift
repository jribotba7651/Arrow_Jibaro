import SwiftUI
import ArrowsCore

/// A single arrow glyph, drawn with the selected skin and rotated to match its
/// direction.
struct ArrowView: View {
    let direction: Direction
    @AppStorage(SettingsKey.skin) private var skinRaw = ArrowSkin.classic.rawValue

    private var skin: ArrowSkin { ArrowSkin(rawValue: skinRaw) ?? .classic }

    var body: some View {
        Image(systemName: skin.symbolName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(skin.tint)
            .rotationEffect(rotation)
    }

    private var rotation: Angle {
        switch direction {
        case .up:    return .degrees(0)
        case .right: return .degrees(90)
        case .down:  return .degrees(180)
        case .left:  return .degrees(270)
        }
    }
}
