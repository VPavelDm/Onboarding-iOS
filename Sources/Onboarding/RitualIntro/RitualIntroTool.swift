import Foundation

/// One card on the ritual intro step: a habit tool the app offers, shown as an icon with a short
/// label, which turns over to explain itself. The host localizes every string.
public struct RitualIntroTool: Identifiable, Hashable, Sendable {
    public let id: String
    /// An SF Symbol name.
    public let systemImage: String
    public let title: String
    public let subtitle: String
    /// What the back of the card says.
    public let detail: String

    public init(id: String, systemImage: String, title: String, subtitle: String, detail: String) {
        self.id = id
        self.systemImage = systemImage
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
    }
}

/// The words around the ritual intro's cards, localized by the host.
public struct RitualIntroStepCopy: Sendable {
    public var title: String
    public var description: String
    public var buttonTitle: String

    public init(title: String, description: String, buttonTitle: String) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
    }
}
