//
//  PaywallTabRule.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation

/// Which tab a plan belongs on. The host decides from the plan and its level
/// in its App Store subscription group (`PaywallPlacementPlans` reads the
/// level from StoreKit; nil when it is unknown). Returning nil places the
/// plan nowhere, which keeps the placement untabbed: no tab ever holds a
/// plan of another kind by accident.
public struct PaywallTabRule: Sendable {

    /// The tab id for a plan at a group level, or nil.
    public let tab: @Sendable (PaywallPlan, Int?) -> String?

    public init(_ tab: @escaping @Sendable (PaywallPlan, Int?) -> String?) {
        self.tab = tab
    }

    /// A rule on the group level alone: `.byGroupLevel { $0 == 1 ? "pro" :
    /// "basic" }`. The levels and tab ids are the host's; a plan whose level
    /// is unknown is placed nowhere.
    public static func byGroupLevel(_ tab: @escaping @Sendable (Int) -> String?) -> PaywallTabRule {
        PaywallTabRule { _, level in level.flatMap(tab) }
    }
}
