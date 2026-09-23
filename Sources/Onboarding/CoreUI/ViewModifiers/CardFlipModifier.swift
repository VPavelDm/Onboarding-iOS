import SwiftUI

extension View {

    /// Turns the view over to show [back] when [isFlipped], rotating about the vertical axis. Each
    /// face is hidden once it has turned past the edge, so neither shows through mirrored.
    func cardFlip<Back: View>(isFlipped: Bool, @ViewBuilder back: @escaping () -> Back) -> some View {
        modifier(CardFlipModifier(isFlipped: isFlipped, back: back))
    }
}

private struct CardFlipModifier<Back: View>: ViewModifier, Animatable {
    var rotation: Double
    let back: () -> Back

    init(isFlipped: Bool, @ViewBuilder back: @escaping () -> Back) {
        self.rotation = isFlipped ? 180 : 0
        self.back = back
    }

    private var isFaceUp: Bool { rotation < 90 }

    nonisolated var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }

    func body(content: Content) -> some View {
        ZStack {
            content.opacity(isFaceUp ? 1 : 0)
            back()
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFaceUp ? 0 : 1)
        }
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
    }
}
