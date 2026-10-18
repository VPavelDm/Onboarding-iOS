//
//  PaywallIntroOffer.swift
//  onboarding-ios
//
//  Created by Claude on 18.10.26.
//

import Foundation

/// A paid introductory price for a plan's first billing period: $2.99 for
/// the first week of a $5.99/week plan. The store charges it once, to a user
/// eligible for the subscription group's introductory offer; the plan's
/// regular price follows. A free trial is `PaywallPlan.freeTrialDays`
/// instead, and an offer longer than one period isn't modelled: the plan then
/// shows its regular price alone, as before this type existed.
public struct PaywallIntroOffer: Hashable, Sendable {

    /// What the first period costs, in the store's currency.
    public let price: Double
    public let localizedPrice: String
    /// How long the introductory price lasts: one week, month or year.
    public let period: PaywallPlan.Period

    public init(price: Double, localizedPrice: String, period: PaywallPlan.Period) {
        self.price = price
        self.localizedPrice = localizedPrice
        self.period = period
    }

    /// "$2.99 for the first week": what the offer is, on the plan and under
    /// the CTA. Guideline 3.1.2 asks for its price and length to be plain.
    var terms: String {
        switch period {
        case .weekly: String(localized: "\(localizedPrice) for the first week", bundle: .module)
        case .monthly: String(localized: "\(localizedPrice) for the first month", bundle: .module)
        case .yearly: String(localized: "\(localizedPrice) for the first year", bundle: .module)
        case .lifetime: localizedPrice
        }
    }
}
