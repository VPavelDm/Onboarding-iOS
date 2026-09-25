//
//  FakePaywallService.swift
//  onboarding-ios
//
//  Created by Claude on 24.09.26.
//

import Foundation
@testable import Paywalls

/// Serves fixed offerings (or fails to) and counts reported views; purchases and
/// restores are never exercised here.
@MainActor
final class FakePaywallService: PaywallServiceProtocol {
    let offerings: PaywallOfferings
    let fetchFails: Bool
    private(set) var shownCount = 0

    init(plans: [PaywallPlan], fetchFails: Bool = false) {
        offerings = PaywallOfferings(plans: plans)
        self.fetchFails = fetchFails
    }

    func fetchOfferings() async throws -> PaywallOfferings {
        if fetchFails { throw URLError(.notConnectedToInternet) }
        return offerings
    }
    func logPaywallShown() async { shownCount += 1 }
    func purchase(plan: PaywallPlan) async -> PaywallPurchaseOutcome { .cancelled }
    func restorePurchases() async -> PaywallRestoreOutcome { .notEntitled }
}
