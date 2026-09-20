import SwiftUI

public struct AdaptiveDivider: View {
    let color: Color

    public init(color: Color) {
        self.color = color
    }

    public var body: some View {
        Divider()
            .overlay(color)
    }
}
