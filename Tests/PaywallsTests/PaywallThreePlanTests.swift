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

    @Test func test_regularPrice_whenThePeriodIsListed_thenTwiceThePlansPriceEndingIn99() async {
        let viewModel = await loadedViewModel(PaywallConfiguration(features: [], trialUnlockBody: "", regularPricePeriods: [.yearly]))

        #expect(viewModel.regularPrice(for: yearly) == 99.99.formatted(.currency(code: "USD").locale(Self.us)))
    }

    @Test func test_regularPrice_whenThePeriodIsNotListed_thenNil() async {
        let viewModel = await loadedViewModel(PaywallConfiguration(features: [], trialUnlockBody: "", regularPricePeriods: [.yearly]))

        #expect(viewModel.regularPrice(for: weekly) == nil)
        #expect(viewModel.regularPrice(for: monthly) == nil)
    }

    @Test func test_regularPrice_whenSeveralPeriodsAreListed_thenEachOfThem() async {
        let viewModel = await loadedViewModel(PaywallConfiguration(features: [], trialUnlockBody: "", regularPricePeriods: [.weekly, .monthly]))

        #expect(viewModel.regularPrice(for: weekly) == 9.99.formatted(.currency(code: "USD").locale(Self.us)))
        #expect(viewModel.regularPrice(for: monthly) == 39.99.formatted(.currency(code: "USD").locale(Self.us)))
        #expect(viewModel.regularPrice(for: yearly) == nil)
    }

    @Test func test_endingIn99_thenKeepsTheWholeUnitsAndSetsTheCents() {
        #expect(yearly.endingIn99(99.98) == 99.99)
        #expect(yearly.endingIn99(120) == 120.99)
        #expect(yearly.endingIn99(119.99) == 119.99)
    }

    @Test func test_endingIn99_whenTheCurrencyHasNoCents_thenUnchanged() {
        let yen = PaywallPlan(id: "y", period: .yearly, price: 1200, localizedPrice: "¥1,200", freeTrialDays: nil, priceLocale: Locale(identifier: "ja_JP"))

        #expect(yen.endingIn99(2400) == 2400)
    }

    @Test func test_regularPrice_whenNotAskedFor_thenNil() async {
        let viewModel = await loadedViewModel(PaywallConfiguration(features: [], trialUnlockBody: ""))

        #expect(viewModel.regularPrice(for: yearly) == nil)
    }

    private func loadedViewModel(_ configuration: PaywallConfiguration) async -> PaywallViewModel {
        let viewModel = PaywallViewModel(service: FakePaywallService(plans: [monthly, weekly, yearly]), source: "test")
        viewModel.configure(with: configuration)
        await viewModel.loadOfferings()
        return viewModel
    }
}
