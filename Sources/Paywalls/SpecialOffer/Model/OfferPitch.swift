//
//  OfferPitch.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation

/// The special offer's figures, worked out from its one plan: the price
/// struck through, the percent off and the price per day. Also the cadence
/// mapping a host needs to name a sale's product from the cadence the
/// package reports.
public enum OfferPitch {

    /// The price struck through: twice the plan's, with the cents at 99, the
    /// rule the paywall's `regularPricePeriods` uses ($29.99 → $59.99). A
    /// currency without cents doubles plainly; so does a plan with no
    /// storefront locale to tell.
    public static func regularPrice(of plan: PaywallPlan) -> Double {
        plan.endingIn99(plan.price * PaywallViewModel.regularPriceMarkup)
    }

    /// 50 for $29.99 against $59.99.
    public static func percentOff(_ plan: PaywallPlan) -> Int {
        Int(((1 - plan.price / regularPrice(of: plan)) * 100).rounded())
    }

    /// The price per day rounded up to the cent, so "less than" stays true:
    /// $29.99 a year → $0.09. Nil for a lifetime plan.
    public static func pricePerDayCeiling(_ plan: PaywallPlan) -> Double? {
        guard plan.period != .lifetime else { return nil }
        return (plan.price / plan.period.days * 100).rounded(.up) / 100
    }

    /// An amount in the plan's own currency and format; the device's
    /// currency when the plan carries no storefront locale.
    public static func format(_ amount: Double, like plan: PaywallPlan) -> String {
        if let formatted = plan.localized(amount) { return formatted }
        let locale = Locale.current
        return amount.formatted(.currency(code: locale.currency?.identifier ?? "USD").locale(locale))
    }

    /// The package names plans by cadence in its events ("yearly"); this
    /// maps that back to the product id of the plan of that cadence among
    /// `plans`, for a host whose own purchase event wants the product.
    public static func productID(forCadence cadence: String, in plans: [PaywallPlan]?) -> String? {
        plans?.first { $0.analyticsName == cadence }?.id
    }

    /// The package's own name for a cadence in analytics.
    public static func analyticsName(_ period: PaywallPlan.Period) -> String {
        switch period {
        case .weekly: "weekly"
        case .monthly: "monthly"
        case .yearly: "yearly"
        case .lifetime: "lifetime"
        }
    }
}
