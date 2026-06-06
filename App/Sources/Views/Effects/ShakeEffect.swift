import SwiftUI

/// Horizontal shake driven by an animatable value. Animate the bound value by
/// +1 to play one burst of `shakes` oscillations.
struct ShakeEffect: GeometryEffect {
    var amplitude: CGFloat = 9
    var shakes: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let phase = Double(animatableData) * .pi * Double(shakes)
        let translation = Double(amplitude) * sin(phase)
        return ProjectionTransform(CGAffineTransform(translationX: CGFloat(translation), y: 0))
    }
}
