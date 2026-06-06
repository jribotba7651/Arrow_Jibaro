import SwiftUI

/// A cosmetic arrow color. Unlocks are gated by the highest level reached, so
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

    var tint: Color {
        switch self {
        case .classic: return Color(red: 0.09, green: 0.11, blue: 0.27) // deep navy
        case .neon:    return Color(red: 0.13, green: 0.80, blue: 0.45)
        case .sunset:  return Color(red: 0.98, green: 0.45, blue: 0.20)
        case .mono:    return .primary
        case .ocean:   return Color(red: 0.10, green: 0.55, blue: 0.72)
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
