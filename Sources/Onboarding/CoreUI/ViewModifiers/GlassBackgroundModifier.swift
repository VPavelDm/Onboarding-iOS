import SwiftUI

struct GlassBackgroundModifier: ViewModifier {

    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        #if os(Android)
        // `glassEffect` is unavailable in Skip; use a translucent fill + stroke instead.
        content
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            }
        #else
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
        #endif
    }
}

extension View {

    func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius))
    }
}
