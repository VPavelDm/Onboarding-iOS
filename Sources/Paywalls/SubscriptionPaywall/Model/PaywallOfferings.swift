//
//  PaywallOfferings.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import Foundation

/// The plans offered on the paywall (typically two), ordered as configured in the
/// store placement.
public struct PaywallOfferings: Hashable, Sendable {
    public let plans: [PaywallPlan]

    public init(plans: [PaywallPlan]) {
        self.plans = plans
    }

    /// Whether any plan carries a free trial.
    var hasFreeTrial: Bool { plans.contains(where: \.hasFreeTrial) }

    /// The best-value plan that offers a trial (longest cadence among trial plans).
    var trialPlan: PaywallPlan? {
        plans.filter(\.hasFreeTrial).max { $0.period.rank < $1.period.rank }
    }

    /// The longest-cadence plan — the best value when no trial is involved.
    var bestValuePlan: PaywallPlan? {
        plans.max { $0.period.rank < $1.period.rank }
    }

    /// The plan selected by default: the trial plan if any, otherwise the best value.
    var defaultPlan: PaywallPlan? { trialPlan ?? bestValuePlan }

    /// The priciest-per-day plan, used as the baseline for savings percentages.
    private var baselinePlan: PaywallPlan? {
        plans.max { $0.pricePerDay < $1.pricePerDay }
    }

    /// A locale-formatted savings badge (e.g. "−30%") for `plan` vs. the priciest-per-day
    /// plan, or nil if it isn't at least 1% cheaper. Lifetime plans have no cadence to
    /// normalise per day, so they neither earn a badge nor serve as the baseline.
    func savingsBadge(for plan: PaywallPlan) -> String? {
        guard
            plan.period != .lifetime,
            let baseline = baselinePlan,
            baseline.period != .lifetime,
            baseline.id != plan.id,
            baseline.pricePerDay > 0,
            plan.pricePerDay < baseline.pricePerDay
        else {
            return nil
        }

        let discount = 1 - plan.pricePerDay / baseline.pricePerDay
        guard discount >= 0.01 else { return nil }

        // Negative so the locale renders its own minus and percent symbols.
        return (-discount).formatted(.percent.rounded(rule: .towardZero).precision(.fractionLength(0)))
    }
}
