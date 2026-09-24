//
//  PaywallOfferings.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import Foundation

/// The plans offered on the paywall (two or three), ordered as configured in the
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

    /// The host's featured plan when the offering has one of that cadence, otherwise
    /// the library's default.
    func defaultPlan(featuring period: PaywallPlan.Period?) -> PaywallPlan? {
        plans.first { $0.period == period } ?? defaultPlan
    }

    /// Whether `plan` saves the most of all plans — ties go to the first listed.
    func isBiggestSaving(_ plan: PaywallPlan) -> Bool {
        let best = plans
            .compactMap { candidate in savingsPercent(for: candidate).map { (candidate, $0) } }
            .max { $0.1 < $1.1 }
        return best?.0.id == plan.id
    }

    /// The priciest-per-day plan, used as the baseline for savings percentages.
    private var baselinePlan: PaywallPlan? {
        plans.max { $0.pricePerDay < $1.pricePerDay }
    }

    /// How much cheaper `plan` is per day than the priciest-per-day plan, rounded
    /// down (e.g. 87), or nil if it isn't at least 1% cheaper. Lifetime plans have
    /// no cadence to normalise per day, so they neither earn a figure nor serve as
    /// the baseline. The tile words it ("Save 87%"); until 2.10 this returned the
    /// locale's own "-87 %", which read as a price drop rather than a saving.
    func savingsPercent(for plan: PaywallPlan) -> Int? {
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

        let percent = Int(((1 - plan.pricePerDay / baseline.pricePerDay) * 100).rounded(.towardZero))
        return percent >= 1 ? percent : nil
    }
}
