//
//  PaywallPlan.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import Foundation

/// A purchasable plan shown on the paywall, decoupled from the store SDK.
public struct PaywallPlan: Identifiable, Hashable, Sendable {

    /// The billing cadence, used for tile copy, ordering, and per-day normalisation.
    /// `.lifetime` is a one-time (non-consumable) purchase — no cadence, no trial.
    public enum Period: Hashable, Sendable {
        case weekly, monthly, yearly, lifetime

        var title: String {
            switch self {
            case .weekly: String(localized: "Weekly", bundle: .module)
            case .monthly: String(localized: "Monthly", bundle: .module)
            case .yearly: String(localized: "Yearly", bundle: .module)
            case .lifetime: String(localized: "Lifetime", bundle: .module)
            }
        }

        /// How the plan is billed, for the tile subtitle.
        var billedCadence: String {
            switch self {
            case .weekly: String(localized: "Billed weekly", bundle: .module)
            case .monthly: String(localized: "Billed monthly", bundle: .module)
            case .yearly: String(localized: "Billed yearly", bundle: .module)
            case .lifetime: String(localized: "One-time payment", bundle: .module)
            }
        }

        /// Approximate length in days, for savings math. Lifetime has no cadence to
        /// normalise against — savings badges exclude it.
        var days: Double {
            switch self {
            case .weekly: 7
            case .monthly: 30
            case .yearly: 365
            case .lifetime: .infinity
            }
        }

        /// Length in weeks, for the per-week price; nil for lifetime.
        var weeks: Double? {
            switch self {
            case .weekly: 1
            case .monthly: 52.0 / 12
            case .yearly: 52
            case .lifetime: nil
            }
        }

        /// Display order (shortest → longest) and "longer = better value" ranking.
        var rank: Int {
            switch self {
            case .weekly: 0
            case .monthly: 1
            case .yearly: 2
            case .lifetime: 3
            }
        }
    }

    public let id: String
    public let period: Period
    public let price: Double
    public let localizedPrice: String
    /// Length of the introductory free trial in days, or nil if the plan has none.
    public let freeTrialDays: Int?
    /// The product's store display name (e.g. "Futura Forever"), shown on the
    /// single-plan price card. Falls back to the period title when nil.
    public let localizedTitle: String?
    /// The storefront locale the store formats this product's price in (currency and
    /// number style). Needed to phrase a derived price such as the per-week figure the
    /// way `localizedPrice` reads — the device's own region can differ ("4,99 US$"
    /// under "$4.99"). Nil hides those figures.
    public let priceLocale: Locale?

    public init(
        id: String,
        period: Period,
        price: Double,
        localizedPrice: String,
        freeTrialDays: Int?,
        localizedTitle: String? = nil,
        priceLocale: Locale? = nil
    ) {
        self.id = id
        self.period = period
        self.price = price
        self.localizedPrice = localizedPrice
        self.freeTrialDays = freeTrialDays
        self.localizedTitle = localizedTitle
        self.priceLocale = priceLocale
    }

    public var hasFreeTrial: Bool { freeTrialDays != nil }

    /// Price normalised per day, for comparing plans of different cadences.
    var pricePerDay: Double { price / period.days }

    /// What the plan costs per week, formatted like `localizedPrice` ("$0.96"), or nil
    /// when there is no storefront locale to format in or no cadence to divide by. A
    /// month counts as 52/12 weeks, the way stores quote it, rather than the 30 days
    /// the savings math uses.
    var localizedPricePerWeek: String? {
        guard let priceLocale, let currency = priceLocale.currency, let weeks = period.weeks else { return nil }
        return (price / weeks).formatted(.currency(code: currency.identifier).locale(priceLocale))
    }
}
