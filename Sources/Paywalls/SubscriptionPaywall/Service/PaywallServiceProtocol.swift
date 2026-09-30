//
//  PaywallServiceProtocol.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import Foundation

/// Abstracts product fetching and purchasing so the paywall UI stays SDK-agnostic.
@MainActor
public protocol PaywallServiceProtocol {
    func fetchOfferings() async throws -> PaywallOfferings
    func purchase(plan: PaywallPlan) async -> PaywallPurchaseOutcome
    func restorePurchases() async -> PaywallRestoreOutcome
    /// Reports that the fetched paywall is on screen, for stores that count views
    /// themselves (Adapty's conversion stats need it for custom paywalls).
    func logPaywallShown() async
    /// Re-reads the entitlement after a purchase made outside `purchase(plan:)` —
    /// an offer code redeemed in Apple's sheet — without prompting the user.
    /// Returns true when it is active.
    func syncEntitlement() async -> Bool
}

public extension PaywallServiceProtocol {
    func logPaywallShown() async {}
    func syncEntitlement() async -> Bool { false }
}
