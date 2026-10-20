//
//  FakePaywallService.swift
//  onboarding-ios
//
//  Created by Claude on 24.09.26.
//

import Foundation
@testable import Paywalls

/// Serves fixed offerings (or fails to), answers purchases, restores and entitlement reads as
/// told, and records what it was asked.
@MainActor
final class FakePaywallService: PaywallServiceProtocol {
    let offerings: PaywallOfferings
    var fetchFails: Bool
    var purchaseOutcome: PaywallPurchaseOutcome = .cancelled
    var restoreOutcome: PaywallRestoreOutcome = .notEntitled
    var isEntitled = false
    private(set) var shownCount = 0
    private(set) var fetchCount = 0
    private(set) var purchasedPlanIDs: [String] = []
    private(set) var syncCount = 0

    init(plans: [PaywallPlan], fetchFails: Bool = false) {
        offerings = PaywallOfferings(plans: plans)
        self.fetchFails = fetchFails
    }

    func fetchOfferings() async throws -> PaywallOfferings {
        fetchCount += 1
        if fetchFails { throw URLError(.notConnectedToInternet) }
        return offerings
    }
    func logPaywallShown() async { shownCount += 1 }
    func purchase(plan: PaywallPlan) async -> PaywallPurchaseOutcome {
        purchasedPlanIDs.append(plan.id)
        return purchaseOutcome
    }
    func restorePurchases() async -> PaywallRestoreOutcome { restoreOutcome }
    func syncEntitlement() async -> Bool {
        syncCount += 1
        return isEntitled
    }
}
