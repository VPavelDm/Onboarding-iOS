import Foundation

public struct SubscriptionInfo: Sendable, Equatable, Hashable {
    public let trialDays: Int

    public init(trialDays: Int) {
        self.trialDays = trialDays
    }
}
