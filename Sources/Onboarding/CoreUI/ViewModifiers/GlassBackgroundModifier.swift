import SwiftUI

struct GlassBackgroundModifier: ViewModifier {

    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
        }
    }
}

extension View {

    func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius))
    }
}
