//
//  PaywallThreePlanTests.swift
//  onboarding-ios
//
//  Created by Claude on 24.09.26.
//

import Foundation
import Testing
@testable import Paywalls

@MainActor
struct PaywallThreePlanTests {

    private static let us = Locale(identifier: "en_US")

    private let monthly = PaywallPlan(id: "month", period: .monthly, price: 19.99, localizedPrice: "$19.99", freeTrialDays: nil, priceLocale: Self.us)
    private let weekly = PaywallPlan(id: "week", period: .weekly, price: 4.99, localizedPrice: "$4.99", freeTrialDays: nil, priceLocale: Self.us)
    private let yearly = PaywallPlan(id: "year", period: .yearly, price: 49.99, localizedPrice: "$49.99", freeTrialDays: nil, priceLocale: Self.us)

    @Test func test_localizedPricePerWeek_thenFormatsInTheStorefrontLocale() {
        let german = PaywallPlan(id: "w", period: .weekly, price: 4.99, localizedPrice: "4,99 €", freeTrialDays: nil, priceLocale: Locale(identifier: "de_DE"))

        #expect(german.localizedPricePerWeek?.contains("4,99") == true)
        #expect(german.localizedPricePerWeek?.contains("€") == true)
    }

    @Test func test_localizedPricePerWeek_thenCountsAMonthAsFiftyTwoTwelfthsOfAWeek() {
        #expect(weekly.localizedPricePerWeek == 4.99.formatted(.currency(code: "USD").locale(Self.us)))
        #expect(monthly.localizedPricePerWeek == (19.99 * 12 / 52).formatted(.currency(code: "USD").locale(Self.us)))
        #expect(yearly.localizedPricePerWeek == (49.99 / 52).formatted(.currency(code: "USD").locale(Self.us)))
    }

    @Test func test_localizedPricePerWeek_whenNoLocaleOrLifetime_thenNil() {
        let noLocale = PaywallPlan(id: "m", period: .monthly, price: 19.99, localizedPrice: "$19.99", freeTrialDays: nil)
        let lifetime = PaywallPlan(id: "l", period: .lifetime, price: 99, localizedPrice: "$99", freeTrialDays: nil, priceLocale: Self.us)

        #expect(noLocale.localizedPricePerWeek == nil)
        #expect(lifetime.localizedPricePerWeek == nil)
    }

    @Test func test_loadOfferings_whenAPeriodIsFeatured_thenSelectsItOverTheBestValue() async {
        let viewModel = await loadedViewModel(PaywallConfiguration(features: [], trialUnlockBody: "", featuredPeriod: .weekly))

        #expect(viewModel.selectedPlan?.id == "week")
    }

    @Test func test_loadOfferings_whenNothingIsFeatured_thenSelectsTheLongestCadence() async {
        let viewModel = await loadedViewModel(PaywallConfiguration(features: [], trialUnlockBody: ""))

        #expect(viewModel.selectedPlan?.id == "year")
    }

    @Test func test_tag_whenFeatured_thenPopularAndTheOthersKeepTheirSavings() async {
        let viewModel = await loadedViewModel(PaywallConfiguration(features: [], trialUnlockBody: "", featuredPeriod: .weekly))

        #expect(viewModel.tag(for: weekly) == .popular)
        #expect(viewModel.tag(for: yearly) == .savings(80))
        #expect(viewModel.tag(for: monthly) == .savings(6))
    }

    @Test func test_tag_whenBiggestSavingOnly_thenOnlyTheBestPlanSaysSave() async {
        let viewModel = await loadedViewModel(
            PaywallConfiguration(features: [], trialUnlockBody: "", featuredPeriod: .weekly, savingsTags: .biggestSavingOnly)
        )

        #expect(viewModel.tag(for: yearly) == .savings(80))
        #expect(viewModel.tag(for: monthly) == nil)
    }

    private func loadedViewModel(_ configuration: PaywallConfiguration) async -> PaywallViewModel {
        let viewModel = PaywallViewModel(service: FakePaywallService(plans: [monthly, weekly, yearly]), source: "test")
        viewModel.configure(with: configuration)
        await viewModel.loadOfferings()
        return viewModel
    }
}
