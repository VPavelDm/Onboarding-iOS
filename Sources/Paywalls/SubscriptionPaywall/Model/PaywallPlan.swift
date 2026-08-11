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
    public enum Period: Hashable, Sendable {
        case weekly, monthly, yearly

        var title: String {
            switch self {
            case .weekly: String(localized: "Weekly", bundle: .module)
            case .monthly: String(localized: "Monthly", bundle: .module)
            case .yearly: String(localized: "Yearly", bundle: .module)
            }
        }

        /// How the plan is billed, for the tile subtitle.
        var billedCadence: String {
            switch self {
            case .weekly: String(localized: "Billed weekly", bundle: .module)
            case .monthly: String(localized: "Billed monthly", bundle: .module)
            case .yearly: String(localized: "Billed yearly", bundle: .module)
            }
        }

        /// Approximate length in days, for savings math.
        var days: Double {
            switch self {
            case .weekly: 7
            case .monthly: 30
            case .yearly: 365
            }
        }

        /// Display order (shortest → longest) and "longer = better value" ranking.
        var rank: Int {
            switch self {
            case .weekly: 0
            case .monthly: 1
            case .yearly: 2
            }
        }
    }

    public let id: String
    public let period: Period
    public let price: Double
    public let localizedPrice: String
    /// Length of the introductory free trial in days, or nil if the plan has none.
    public let freeTrialDays: Int?

    public init(id: String, period: Period, price: Double, localizedPrice: String, freeTrialDays: Int?) {
        self.id = id
        self.period = period
        self.price = price
        self.localizedPrice = localizedPrice
        self.freeTrialDays = freeTrialDays
    }

    public var hasFreeTrial: Bool { freeTrialDays != nil }

    /// Price normalised per day, for comparing plans of different cadences.
    var pricePerDay: Double { price / period.days }
}
