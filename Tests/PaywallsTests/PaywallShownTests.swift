//
//  PaywallShownTests.swift
//  onboarding-ios
//
//  Created by Claude on 25.09.26.
//

import Foundation
import Testing
@testable import Paywalls

@MainActor
struct PaywallShownTests {

    private let weekly = PaywallPlan(id: "week", period: .weekly, price: 4.99, localizedPrice: "$4.99", freeTrialDays: nil)

    @Test func test_loadOfferings_whenOfferingsLoad_thenReportsTheViewToTheStore() async {
        let service = FakePaywallService(plans: [weekly])
        let viewModel = PaywallViewModel(service: service, source: "test")

        await viewModel.loadOfferings()

        #expect(service.shownCount == 1)
    }

    @Test func test_loadOfferings_whenShownAgain_thenReportsEachView() async {
        let service = FakePaywallService(plans: [weekly])
        let viewModel = PaywallViewModel(service: service, source: "test")

        await viewModel.loadOfferings()
        await viewModel.loadOfferings()

        #expect(service.shownCount == 2)
    }

    @Test func test_loadOfferings_whenFetchFails_thenReportsNoView() async {
        let service = FakePaywallService(plans: [weekly], fetchFails: true)
        let viewModel = PaywallViewModel(service: service, source: "test")

        await viewModel.loadOfferings()

        #expect(service.shownCount == 0)
    }
}
