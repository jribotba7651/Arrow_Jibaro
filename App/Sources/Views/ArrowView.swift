import SwiftUI
import ArrowsCore

/// An arrow drawn as a single open path centered in its rect: a vertical shaft
/// plus a chevron head, pointing up. `lengthFactor` (0...1) varies the shaft
/// length only — purely cosmetic. Stroked with round caps/joins it reads as the
/// thin, rounded line-art arrow used in the reference art.
struct ArrowShape: Shape {
    var lengthFactor: CGFloat = 1.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let centerX = rect.midX
        let centerY = rect.midY
        let usable = rect.height * 0.88
        let half = usable * max(0.35, min(1.0, lengthFactor)) / 2
        let tipY = centerY - half
        let tailY = centerY + half
        let headH = min(rect.height * 0.24, (tailY - tipY) * 0.6)
        let headW = rect.width * 0.24

        // Shaft.
        path.move(to: CGPoint(x: centerX, y: tailY))
        path.addLine(to: CGPoint(x: centerX, y: tipY))

        // Chevron head.
        path.move(to: CGPoint(x: centerX - headW, y: tipY + headH))
        path.addLine(to: CGPoint(x: centerX, y: tipY))
        path.addLine(to: CGPoint(x: centerX + headW, y: tipY + headH))

        return path
    }
}

/// The arrow glyph in a given color, with a thin stroke scaled to its size.
struct ArrowGlyph: View {
    var color: Color
    var lengthFactor: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            ArrowShape(lengthFactor: lengthFactor).stroke(
                color,
                style: StrokeStyle(
                    lineWidth: min(geo.size.width, geo.size.height) * 0.10,
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
    var lengthFactor: CGFloat = 1.0
    @AppStorage(SettingsKey.skin) private var skinRaw = ArrowSkin.classic.rawValue

    private var skin: ArrowSkin { ArrowSkin(rawValue: skinRaw) ?? .classic }

    var body: some View {
        ArrowGlyph(color: skin.tint, lengthFactor: lengthFactor)
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
