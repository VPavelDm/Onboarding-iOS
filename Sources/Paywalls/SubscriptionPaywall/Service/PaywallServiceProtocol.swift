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
}
