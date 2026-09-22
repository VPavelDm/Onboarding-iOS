//
//  AdaptyPaywallService.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import Foundation
import Adapty
import Paywalls

/// Backs the subscription paywall with Adapty: fetches the placement's products, maps
/// them to plans, and runs purchase/restore. `onEntitlementChanged` runs before any
/// entitled outcome is returned, so the host can refresh its subscription cache and
/// have it current by the time the paywall unlocks.
@MainActor
public final class AdaptyPaywallService: PaywallServiceProtocol {

    private let placementID: String
    private let accessLevelKey: String
    private let onEntitlementChanged: () async -> Void
    private var products: [String: AdaptyPaywallProduct] = [:]

    public init(
        placementID: String,
        accessLevelKey: String = "premium",
        onEntitlementChanged: @escaping () async -> Void = {}
    ) {
        self.placementID = placementID
        self.accessLevelKey = accessLevelKey
        self.onEntitlementChanged = onEntitlementChanged
    }

    public func fetchOfferings() async throws -> PaywallOfferings {
        let paywall = try await Adapty.getPaywall(placementId: placementID)
        let fetched = try await Adapty.getPaywallProducts(paywall: paywall)

        // The paywall shows at most two plans: take the first two products with a
        // recognisable cadence, as configured (and ordered) in the placement.
        let plans = fetched
            .compactMap { product -> PaywallPlan? in
                guard let period = period(of: product) else { return nil }
                return plan(from: product, period: period)
            }
            .prefix(2)

        guard !plans.isEmpty else { throw PaywallError.missingProducts }

        products = Dictionary(
            uniqueKeysWithValues: fetched.map { ($0.vendorProductId, $0) }
        )

        return PaywallOfferings(plans: Array(plans))
    }

    private func period(of product: AdaptyPaywallProduct) -> PaywallPlan.Period? {
        // No subscription period means a one-time (non-consumable) product — a
        // lifetime unlock.
        guard let unit = product.subscriptionPeriod?.unit else { return .lifetime }
        return switch unit {
        case .day, .week: .weekly
        case .month: .monthly
        case .year: .yearly
        default: nil
        }
    }

    public func purchase(plan: PaywallPlan) async -> PaywallPurchaseOutcome {
        guard let product = products[plan.id] else { return .notEntitled }
        do {
            switch try await Adapty.makePurchase(product: product) {
            case let .success(profile, _):
                await onEntitlementChanged()
                return profile.accessLevels[accessLevelKey]?.isActive == true ? .purchased : .notEntitled
            case .userCancelled:
                return .cancelled
            case .pending:
                return .pending
            }
        } catch {
            // An interrupted purchase (e.g. SCA verification bouncing through the
            // App Store) throws here while Apple completes the payment out of band —
            // check whether the entitlement already landed before reporting failure.
            if await isEntitled() {
                await onEntitlementChanged()
                return .purchased
            }
            return .failed("\(error)")
        }
    }

    public func restorePurchases() async -> PaywallRestoreOutcome {
        do {
            let profile = try await Adapty.restorePurchases()
            await onEntitlementChanged()
            return profile.accessLevels[accessLevelKey]?.isActive == true ? .restored : .notEntitled
        } catch {
            return .failed
        }
    }

    private func isEntitled() async -> Bool {
        (try? await Adapty.getProfile())?.accessLevels[accessLevelKey]?.isActive == true
    }

    private func plan(from product: AdaptyPaywallProduct, period: PaywallPlan.Period) -> PaywallPlan {
        PaywallPlan(
            id: product.vendorProductId,
            period: period,
            price: NSDecimalNumber(decimal: product.price).doubleValue,
            localizedPrice: product.localizedPrice ?? "—",
            freeTrialDays: freeTrialDays(of: product),
            localizedTitle: product.localizedTitle
        )
    }

    /// Days of free trial if the product's intro offer is a free-trial offer, else nil.
    private func freeTrialDays(of product: AdaptyPaywallProduct) -> Int? {
        guard let offer = product.subscriptionOffer, offer.paymentMode == .freeTrial else { return nil }
        let unitDays: Double
        switch offer.subscriptionPeriod.unit {
        case .day: unitDays = 1
        case .week: unitDays = 7
        case .month: unitDays = 30
        case .year: unitDays = 365
        default: unitDays = 0
        }
        let days = Int((unitDays * Double(offer.subscriptionPeriod.numberOfUnits) * Double(offer.numberOfPeriods)).rounded())
        return days > 0 ? days : nil
    }
}

enum PaywallError: Error {
    case missingProducts
}
