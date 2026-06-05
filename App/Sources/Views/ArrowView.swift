import SwiftUI
import ArrowsCore

/// An up-pointing arrow drawn as a single open path: a vertical shaft plus a
/// chevron head. Stroked with round caps/joins it reads as the thick, rounded
/// line-art arrow used in the reference art.
struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let centerX = rect.midX
        let topY = rect.minY + rect.height * 0.16
        let bottomY = rect.maxY - rect.height * 0.16
        let headW = rect.width * 0.28
        let headH = rect.height * 0.28

        // Shaft.
        path.move(to: CGPoint(x: centerX, y: bottomY))
        path.addLine(to: CGPoint(x: centerX, y: topY))

        // Chevron head.
        path.move(to: CGPoint(x: centerX - headW, y: topY + headH))
        path.addLine(to: CGPoint(x: centerX, y: topY))
        path.addLine(to: CGPoint(x: centerX + headW, y: topY + headH))

        return path
    }
}

/// The arrow glyph in a given color, with stroke width scaled to its size.
struct ArrowGlyph: View {
    var color: Color

    var body: some View {
        GeometryReader { geo in
            ArrowShape().stroke(
                color,
                style: StrokeStyle(
                    lineWidth: min(geo.size.width, geo.size.height) * 0.16,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}

/// A single arrow, drawn with the selected skin and rotated to its direction.
struct ArrowView: View {
    let direction: Direction
    @AppStorage(SettingsKey.skin) private var skinRaw = ArrowSkin.classic.rawValue

    private var skin: ArrowSkin { ArrowSkin(rawValue: skinRaw) ?? .classic }

    var body: some View {
        ArrowGlyph(color: skin.tint)
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
