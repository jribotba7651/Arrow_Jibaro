import SwiftUI

/// A cosmetic arrow style. Unlocks are gated by the highest level reached, so
/// the collection rewards progress without affecting the mechanic.
enum ArrowSkin: String, CaseIterable, Identifiable {
    case classic, neon, sunset, mono, ocean

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .neon:    return "Neon"
        case .sunset:  return "Sunset"
        case .mono:    return "Mono"
        case .ocean:   return "Ocean"
        }
    }

    /// SF Symbol used to draw the arrow (always points up; rotated per direction).
    var symbolName: String {
        switch self {
        case .classic: return "arrow.up"
        case .neon:    return "arrow.up"
        case .sunset:  return "arrowtriangle.up.fill"
        case .mono:    return "arrow.up"
        case .ocean:   return "arrowshape.up.fill"
        }
    }

    var tint: Color {
        switch self {
        case .classic: return .blue
        case .neon:    return .green
        case .sunset:  return .orange
        case .mono:    return .primary
        case .ocean:   return .teal
        }
    }

    /// `highestLevelReached` required to unlock this skin.
    var unlockLevel: Int {
        switch self {
        case .classic: return 1
        case .neon:    return 3
        case .sunset:  return 5
        case .mono:    return 8
        case .ocean:   return 12
        }
    }
}
