import SwiftUI

/// The card surface the flow's steps share: a material fill under a hairline lit along the top
/// edge that fades out by the middle. It matches the card grid's tiles, so every card in a flow
/// reads as the same object. Liquid Glass is not used — it draws no edge of its own, and it drops
/// out inside a `rotation3DEffect`, which a flipping card needs.
struct GlassBackgroundModifier: ViewModifier {

    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.cardEdge, lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }
}

extension View {

    func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius))
    }
}

private extension ShapeStyle where Self == LinearGradient {

    /// White at the top, gone by the centre: the card catches the light from above.
    static var cardEdge: LinearGradient {
        LinearGradient(
            colors: [.white.opacity(0.35), .white.opacity(0)],
            startPoint: .top,
            endPoint: .center
        )
    }
}
