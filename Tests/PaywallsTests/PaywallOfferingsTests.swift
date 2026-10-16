//
//  PaywallOfferingsTests.swift
//  onboarding-ios
//

import Foundation
import Testing
@testable import Paywalls

/// Which plan the paywall opens on, and what each tile claims to save. The savings figure is
/// shown to the user as a promise, so it must never round up or compare against a lifetime price.
struct PaywallOfferingsTests {

    private func plan(_ id: String, _ period: PaywallPlan.Period, _ price: Double, trial: Int? = nil) -> PaywallPlan {
        PaywallPlan(id: id, period: period, price: price, localizedPrice: "\(price)", freeTrialDays: trial)
    }

    @Test func test_defaultPlan_whenAShorterPlanHasTheTrial_thenOpensOnTheTrialPlan() {
        let offerings = PaywallOfferings(plans: [
            plan("week", .weekly, 4.99, trial: 3),
            plan("year", .yearly, 29.99),
        ])

        #expect(offerings.defaultPlan?.id == "week")
    }

    @Test func test_defaultPlan_whenSeveralPlansHaveTrials_thenTheLongestOfThem() {
        let offerings = PaywallOfferings(plans: [
            plan("week", .weekly, 4.99, trial: 3),
            plan("month", .monthly, 9.99, trial: 7),
            plan("year", .yearly, 29.99),
        ])

        #expect(offerings.defaultPlan?.id == "month")
    }

    @Test func test_defaultPlan_whenTheFeaturedPeriodIsNotOffered_thenFallsBackToTheDefault() {
        let offerings = PaywallOfferings(plans: [plan("month", .monthly, 9.99), plan("year", .yearly, 29.99)])

        #expect(offerings.defaultPlan(featuring: .weekly)?.id == "year")
    }

    @Test func test_savingsPercent_thenRoundsDownAgainstThePriciestPerDay() {
        // 29.99 a year against 4.99 a week: 0.0822 vs 0.7129 a day, 88.47% cheaper.
        let week = plan("week", .weekly, 4.99)
        let year = plan("year", .yearly, 29.99)
        let offerings = PaywallOfferings(plans: [week, year])

        #expect(offerings.savingsPercent(for: year) == 88)
        #expect(offerings.savingsPercent(for: week) == nil, "The baseline saves nothing against itself")
    }

    @Test func test_savingsPercent_whenUnderOnePercent_thenNone() {
        let month = plan("month", .monthly, 30)
        let year = plan("year", .yearly, 364)
        let offerings = PaywallOfferings(plans: [month, year])

        #expect(offerings.savingsPercent(for: year) == nil)
    }

    /// A lifetime price has no cadence to compare per day.
    @Test func test_savingsPercent_whenLifetime_thenNoneAndItIsNeverTheBaseline() {
        let month = plan("month", .monthly, 9.99)
        let year = plan("year", .yearly, 59.99)
        let lifetime = plan("life", .lifetime, 99)
        let offerings = PaywallOfferings(plans: [month, year, lifetime])

        #expect(offerings.savingsPercent(for: lifetime) == nil)
        // 59.99 a year against 9.99 a month: 0.1644 vs 0.333 a day, 50.6% cheaper.
        #expect(offerings.savingsPercent(for: year) == 50)
    }

    @Test func test_isBiggestSaving_whenTwoPlansTie_thenTheFirstListedWins() {
        let week = plan("week", .weekly, 7)
        let monthA = plan("a", .monthly, 15)
        let monthB = plan("b", .monthly, 15)
        let offerings = PaywallOfferings(plans: [week, monthA, monthB])

        #expect(offerings.isBiggestSaving(monthA))
        #expect(offerings.isBiggestSaving(monthB) == false)
    }
}
