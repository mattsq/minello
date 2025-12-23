#if canImport(UIKit)
import UIKit
#endif

/// Provides haptic feedback for user interactions
enum Haptics {
    /// Provides success haptic feedback (e.g., when a card is successfully dropped)
    static func success() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    /// Provides error haptic feedback (e.g., when a drag operation fails)
    static func error() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }

    /// Provides warning haptic feedback
    static func warning() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }

    /// Provides light impact feedback (e.g., when picking up a card)
    static func lightImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }

    /// Provides medium impact feedback
    static func mediumImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }

    /// Provides heavy impact feedback
    static func heavyImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }

    /// Provides selection changed feedback (e.g., when dragging over different columns)
    static func selectionChanged() {
        #if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
}
