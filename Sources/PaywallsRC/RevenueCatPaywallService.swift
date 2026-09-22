import Foundation
import Paywalls
import RevenueCat

/// Serves the paywall from RevenueCat. The offering and entitlement it reads are the host's to
/// name, because those identifiers are configured per app in the RevenueCat dashboard.
@MainActor
public final class RevenueCatPaywallService: PaywallServiceProtocol {

    private let offeringID: String?
    private let entitlementID: String
    private var packages: [String: Package] = [:]

    /// - Parameters:
    ///   - offeringID: The offering to show, or nil for the current one.
    ///   - entitlementID: The entitlement a successful purchase must activate.
    public init(offeringID: String? = nil, entitlementID: String) {
        self.offeringID = offeringID
        self.entitlementID = entitlementID
    }

    public func fetchOfferings() async throws -> PaywallOfferings {
        let offerings = try await Purchases.shared.offerings()
        guard let offering = offeringID.map({ offerings.all[$0] }) ?? offerings.current else {
            throw PaywallError.noOfferings
        }

        let plans = offering.availablePackages.compactMap(plan(from:))
        guard !plans.isEmpty else { throw PaywallError.noOfferings }

        return PaywallOfferings(plans: plans)
    }

    public func purchase(plan: PaywallPlan) async -> PaywallPurchaseOutcome {
        guard let package = packages[plan.id] else { return .failed("unknown_plan") }
        do {
            let result = try await Purchases.shared.purchase(package: package)
            guard !result.userCancelled else { return .cancelled }
            return isEntitled(result.customerInfo) ? .purchased : .notEntitled
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    public func restorePurchases() async -> PaywallRestoreOutcome {
        do {
            return isEntitled(try await Purchases.shared.restorePurchases()) ? .restored : .notEntitled
        } catch {
            return .failed
        }
    }

    private func isEntitled(_ info: CustomerInfo) -> Bool {
        info.entitlements[entitlementID]?.isActive == true
    }

    /// A package whose cadence the paywall has no period for is dropped rather than guessed at:
    /// the tiles are built around comparing prices per day, which needs a cadence.
    private func plan(from package: Package) -> PaywallPlan? {
        guard let period = period(of: package) else { return nil }
        packages[package.identifier] = package

        let product = package.storeProduct
        return PaywallPlan(
            id: package.identifier,
            period: period,
            price: (product.price as NSDecimalNumber).doubleValue,
            localizedPrice: product.localizedPriceString,
            freeTrialDays: freeTrialDays(of: product),
            localizedTitle: product.localizedTitle
        )
    }

    private func period(of package: Package) -> PaywallPlan.Period? {
        switch package.packageType {
        case .annual: .yearly
        case .monthly: .monthly
        case .weekly: .weekly
        case .lifetime: .lifetime
        default: nil
        }
    }

    /// Only a free introductory offer is a trial; a discounted first period is not one, and the
    /// timeline would date it wrongly.
    private func freeTrialDays(of product: StoreProduct) -> Int? {
        guard
            let offer = product.introductoryDiscount,
            offer.paymentMode == .freeTrial
        else {
            return nil
        }
        return days(in: offer.subscriptionPeriod)
    }

    private func days(in period: SubscriptionPeriod) -> Int {
        switch period.unit {
        case .day: period.value
        case .week: period.value * 7
        case .month: period.value * 30
        case .year: period.value * 365
        @unknown default: period.value
        }
    }

    private enum PaywallError: Error {
        case noOfferings
    }
}
