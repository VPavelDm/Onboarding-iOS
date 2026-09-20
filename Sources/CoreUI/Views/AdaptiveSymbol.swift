import SwiftUI

public struct AdaptiveSymbol: View {
    let systemName: String
    let emoji: String

    public init(systemName: String, emoji: String) {
        self.systemName = systemName
        self.emoji = emoji
    }

    public var body: some View {
        Image(systemName: systemName)
    }
}
