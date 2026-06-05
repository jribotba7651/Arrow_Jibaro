import SwiftUI
import ArrowsCore

/// A single arrow glyph, rotated to match its direction.
struct ArrowView: View {
    let direction: Direction

    var body: some View {
        Image(systemName: "arrow.up")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.tint)
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
