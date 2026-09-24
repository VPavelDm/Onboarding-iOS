//
//  FakePaywallService.swift
//  onboarding-ios
//
//  Created by Claude on 24.09.26.
//

import Foundation
@testable import Paywalls

/// Serves fixed offerings; purchases and restores are never exercised here.
@MainActor
final class FakePaywallService: PaywallServiceProtocol {
    let offerings: PaywallOfferings

    init(plans: [PaywallPlan]) {
        offerings = PaywallOfferings(plans: plans)
    }

    func fetchOfferings() async throws -> PaywallOfferings { offerings }
    func purchase(plan: PaywallPlan) async -> PaywallPurchaseOutcome { .cancelled }
    func restorePurchases() async -> PaywallRestoreOutcome { .notEntitled }
}
