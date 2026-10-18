//
//  PaywallIntroOfferTests.swift
//  onboarding-ios
//
//  Created by Claude on 18.10.26.
//

import Foundation
import Testing
@testable import Paywalls

@MainActor
struct PaywallIntroOfferTests {

    private let introWeek = PaywallIntroOffer(price: 2.99, localizedPrice: "$2.99", period: .weekly)
    private let monthly = PaywallPlan(id: "month", period: .monthly, price: 8.99, localizedPrice: "$8.99", freeTrialDays: 3)

    @Test func test_terms_whenOneWeek_thenNamesThePriceAndTheWeek() {
        #expect(introWeek.terms == "$2.99 for the first week")
    }

    @Test func test_terms_whenOneMonthOrYear_thenNamesThatPeriod() {
        let month = PaywallIntroOffer(price: 0.99, localizedPrice: "$0.99", period: .monthly)
        let year = PaywallIntroOffer(price: 19.99, localizedPrice: "$19.99", period: .yearly)

        #expect(month.terms == "$0.99 for the first month")
        #expect(year.terms == "$19.99 for the first year")
    }

    @Test func test_plan_whenBuiltWithoutOffer_thenHasNone() {
        #expect(monthly.introOffer == nil)
    }

    @Test func test_selectedIntroOffer_whenSelectionChanges_thenFollowsTheSelectedPlan() async {
        let weekly = PaywallPlan(id: "week", period: .weekly, price: 5.99, localizedPrice: "$5.99", freeTrialDays: nil, introOffer: introWeek)
        let viewModel = PaywallViewModel(service: FakePaywallService(plans: [weekly, monthly]), source: "test")
        await viewModel.loadOfferings()

        viewModel.selectPlan(weekly)
        #expect(viewModel.selectedIntroOffer == introWeek)

        viewModel.selectPlan(monthly)
        #expect(viewModel.selectedIntroOffer == nil)
    }
}
