import SwiftUI

public struct AdaptiveDivider: View {
    let color: Color

    public init(color: Color) {
        self.color = color
    }

    public var body: some View {
        #if os(Android)
        Rectangle()
            .fill(color)
            .frame(height: 1)
        #else
        Divider()
            .overlay(color)
        #endif
    }
}
