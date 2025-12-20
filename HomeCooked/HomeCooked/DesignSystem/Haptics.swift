import UIKit

/// Haptic feedback utilities for enhanced user interaction
enum Haptics {
    /// Play haptic feedback for successful drag-and-drop operation
    static func playDropSuccess() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Play haptic feedback when a drag operation starts
    static func playDragStart() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Play haptic feedback when dragging over a valid drop target
    static func playDragOver() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    /// Play haptic feedback when a drag operation is cancelled
    static func playDragCancel() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Play haptic feedback for general selection
    static func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
