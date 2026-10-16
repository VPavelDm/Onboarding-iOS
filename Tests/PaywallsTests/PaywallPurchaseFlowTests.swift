//
//  PaywallPurchaseFlowTests.swift
//  onboarding-ios
//

import Foundation
import StoreKit
import Testing
@testable import Paywalls

/// What the paywall does with each answer from the store: what it unlocks, what it tells the
/// user, and what it reports. A purchase that goes through but isn't reported is lost revenue in
/// the numbers; one reported that didn't go through is worse.
@MainActor
struct PaywallPurchaseFlowTests {

    private static let us = Locale(identifier: "en_US")
    private let yearly = PaywallPlan(id: "year", period: .yearly, price: 29.99, localizedPrice: "$29.99", freeTrialDays: 3, priceLocale: Self.us)
    private let monthly = PaywallPlan(id: "month", period: .monthly, price: 4.99, localizedPrice: "$4.99", freeTrialDays: nil, priceLocale: Self.us)

    /// Every event the view model reports, in order.
    private final class Events {
        var all: [(name: String, parameters: [String: Any])] = []
        var names: [String] { all.map(\.name) }
        func parameters(of name: String) -> [String: Any]? { all.last { $0.name == name }?.parameters }
    }

    private func loaded(_ service: FakePaywallService, events: Events = Events()) async -> PaywallViewModel {
        let viewModel = PaywallViewModel(service: service, source: "onboarding") { events.all.append(($0, $1)) }
        await viewModel.loadOfferings()
        return viewModel
    }

    // MARK: - Purchase

    @Test func test_purchase_whenPurchased_thenUnlocksAndReportsTheSubscription() async {
        let service = FakePaywallService(plans: [yearly, monthly])
        service.purchaseOutcome = .purchased
        let events = Events()
        let viewModel = await loaded(service, events: events)

        let unlocked = await viewModel.purchase()

        #expect(unlocked)
        #expect(service.purchasedPlanIDs == ["year"])
        #expect(events.parameters(of: "subscription_started")?["plan"] as? String == "yearly")
        #expect(viewModel.isPurchasing == false)
        #expect(viewModel.purchaseError == nil)
    }

    @Test func test_purchase_whenCancelled_thenStaysLockedWithoutAnError() async {
        let service = FakePaywallService(plans: [yearly, monthly])
        service.purchaseOutcome = .cancelled
        let events = Events()
        let viewModel = await loaded(service, events: events)

        #expect(await viewModel.purchase() == false)
        #expect(viewModel.purchaseError == nil)
        #expect(events.names.contains("subscription_purchase_cancelled"))
        #expect(!events.names.contains("subscription_started"))
    }

    /// Ask to Buy: the unlock arrives later, so the button stays busy and the user is told why.
    @Test func test_purchase_whenPendingApproval_thenWaitsAndSaysSo() async {
        let service = FakePaywallService(plans: [yearly, monthly])
        service.purchaseOutcome = .pending
        let viewModel = await loaded(service)

        #expect(await viewModel.purchase() == false)
        #expect(viewModel.isPendingApproval)
        #expect(viewModel.showPendingApprovalAlert)
        #expect(viewModel.purchaseError == nil)
    }

    @Test func test_purchase_whenPaidButNotEntitled_thenShowsAnError() async {
        let service = FakePaywallService(plans: [yearly, monthly])
        service.purchaseOutcome = .notEntitled
        let events = Events()
        let viewModel = await loaded(service, events: events)

        #expect(await viewModel.purchase() == false)
        #expect(viewModel.purchaseError != nil)
        #expect(events.parameters(of: "subscription_purchase_failed")?["message"] as? String == "not_entitled")
    }

    /// The store's diagnostic goes to analytics, never to the user.
    @Test func test_purchase_whenFailed_thenReportsTheDiagnosticAndShowsAPlainError() async {
        let service = FakePaywallService(plans: [yearly, monthly])
        service.purchaseOutcome = .failed("SKErrorDomain 2")
        let events = Events()
        let viewModel = await loaded(service, events: events)

        #expect(await viewModel.purchase() == false)
        #expect(events.parameters(of: "subscription_purchase_failed")?["message"] as? String == "SKErrorDomain 2")
        #expect(viewModel.purchaseError?.contains("SKErrorDomain") == false)
    }

    @Test func test_purchase_whenNothingLoaded_thenDoesNotReachTheStore() async {
        let service = FakePaywallService(plans: [yearly], fetchFails: true)
        let viewModel = await loaded(service)

        #expect(await viewModel.purchase() == false)
        #expect(service.purchasedPlanIDs.isEmpty)
    }

    @Test func test_purchase_thenBuysTheSelectedPlan() async {
        let service = FakePaywallService(plans: [yearly, monthly])
        let viewModel = await loaded(service)

        viewModel.selectPlan(monthly)
        _ = await viewModel.purchase()

        #expect(service.purchasedPlanIDs == ["month"])
    }

    // MARK: - Restore

    @Test func test_restore_whenRestored_thenUnlocks() async {
        let service = FakePaywallService(plans: [yearly])
        service.restoreOutcome = .restored
        let viewModel = await loaded(service)

        #expect(await viewModel.restorePurchases())
        #expect(viewModel.showRestoreFailedAlert == false)
    }

    @Test(arguments: [PaywallRestoreOutcome.notEntitled, .failed])
    func test_restore_whenNothingToRestore_thenSaysItFailed(outcome: PaywallRestoreOutcome) async {
        let service = FakePaywallService(plans: [yearly])
        service.restoreOutcome = outcome
        let viewModel = await loaded(service)

        #expect(await viewModel.restorePurchases() == false)
        #expect(viewModel.showRestoreFailedAlert)
    }

    // MARK: - Offer codes

    @Test func test_codeRedemption_whenTheSheetIsCancelled_thenNeitherSyncsNorUnlocks() async {
        let service = FakePaywallService(plans: [yearly])
        let events = Events()
        let viewModel = await loaded(service, events: events)

        #expect(await viewModel.codeRedemptionFinished(.failure(StoreKitError.userCancelled)) == false)
        #expect(service.syncCount == 0)
        #expect(events.names.contains("offer_code_sheet_cancelled"))
    }

    @Test func test_codeRedemption_whenTheSheetFails_thenReportsTheFailure() async {
        let service = FakePaywallService(plans: [yearly])
        let events = Events()
        let viewModel = await loaded(service, events: events)

        #expect(await viewModel.codeRedemptionFinished(.failure(URLError(.timedOut))) == false)
        #expect(events.names.contains("offer_code_redemption_failed"))
    }

    /// The sheet only says it closed, so the entitlement is read back to know whether to unlock.
    @Test(arguments: [true, false])
    func test_codeRedemption_whenTheSheetCloses_thenUnlocksOnlyWithTheEntitlement(entitled: Bool) async {
        let service = FakePaywallService(plans: [yearly])
        service.isEntitled = entitled
        let viewModel = await loaded(service)

        #expect(await viewModel.codeRedemptionFinished(.success(())) == entitled)
        #expect(service.syncCount == 1)
    }

    // MARK: - Loading and choosing

    /// There is no way past a hard paywall without a purchase, so a failed load offers a retry.
    @Test func test_loadOfferings_whenTheRetrySucceeds_thenThePlansAppear() async {
        let service = FakePaywallService(plans: [yearly, monthly], fetchFails: true)
        let events = Events()
        let viewModel = await loaded(service, events: events)
        #expect(viewModel.loadFailed)
        #expect(viewModel.ctaTitle == "Retry")
        #expect(events.names.contains("paywall_offerings_failed"))

        service.fetchFails = false
        await viewModel.loadOfferings()

        #expect(viewModel.loadFailed == false)
        #expect(viewModel.plans.map(\.id) == ["year", "month"])
    }

    @Test func test_ctaTitle_thenNamesTheTrialOnlyWhenTheSelectedPlanHasOne() async {
        let viewModel = await loaded(FakePaywallService(plans: [yearly, monthly]))

        #expect(viewModel.ctaTitle == "Try 3 Days Free")
        viewModel.selectPlan(monthly)
        #expect(viewModel.ctaTitle == "Continue")
    }

    /// The timeline keeps the offering's trial while the selection moves to a plan without one.
    @Test func test_trialDays_thenComesFromTheOfferingNotTheSelection() async {
        let viewModel = await loaded(FakePaywallService(plans: [yearly, monthly]))

        viewModel.selectPlan(monthly)

        #expect(viewModel.selectedHasTrial == false)
        #expect(viewModel.trialDays == 3)
    }

    @Test func test_selectPlan_whenAlreadySelected_thenReportsNothing() async {
        let events = Events()
        let viewModel = await loaded(FakePaywallService(plans: [yearly, monthly]), events: events)

        viewModel.selectPlan(yearly)
        viewModel.selectPlan(monthly)

        #expect(events.names.filter { $0 == "paywall_plan_selected" }.count == 1)
        #expect(events.parameters(of: "paywall_plan_selected")?["plan"] as? String == "monthly")
    }

    @Test func test_events_thenEachCarriesThePlacement() async {
        let service = FakePaywallService(plans: [yearly, monthly])
        service.purchaseOutcome = .purchased
        let events = Events()
        let viewModel = await loaded(service, events: events)

        viewModel.selectPlan(monthly)
        _ = await viewModel.purchase()
        viewModel.userDismissed()

        #expect(!events.all.isEmpty)
        #expect(events.all.allSatisfy { $0.parameters["source"] as? String == "onboarding" })
    }

    /// The corner close and the named decline say different things about the pitch.
    @Test func test_dismissals_thenCloseAndDeclineAreReportedApart() async {
        let events = Events()
        let viewModel = await loaded(FakePaywallService(plans: [yearly]), events: events)

        viewModel.userDismissed()
        viewModel.userDeclined()

        #expect(Array(events.names.suffix(2)) == ["paywall_close_button_tapped", "paywall_declined"])
    }
}
