import SwiftUI
import ArrowsCore

/// A short-lived arrow that flies off the board in its direction, used to make a
/// successful shot feel like the arrow actually escaped. Manages its own
/// animation lifecycle and calls `onComplete` when done so the parent can
/// remove it.
struct FlyingArrowView: View {
    let direction: Direction
    let cellSize: CGFloat
    let onComplete: () -> Void

    @State private var progress: CGFloat = 0

    var body: some View {
        ArrowView(direction: direction)
            .padding(cellSize * 0.16)
            .offset(travel)
            .opacity(Double(1 - progress))
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) { progress = 1 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { onComplete() }
            }
    }

    private var travel: CGSize {
        let distance = cellSize * 6 * progress
        switch direction {
        case .up:    return CGSize(width: 0, height: -distance)
        case .down:  return CGSize(width: 0, height: distance)
        case .left:  return CGSize(width: -distance, height: 0)
        case .right: return CGSize(width: distance, height: 0)
        }
    }
}
