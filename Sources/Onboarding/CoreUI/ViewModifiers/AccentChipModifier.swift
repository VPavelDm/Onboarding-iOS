import SwiftUI

struct AccentChipModifier: ViewModifier {

    var color: Color

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.22), in: Capsule())
            .overlay {
                Capsule().strokeBorder(color.opacity(0.6), lineWidth: 0.5)
            }
    }
}

extension View {

    func accentChip(color: Color) -> some View {
        modifier(AccentChipModifier(color: color))
    }
}
