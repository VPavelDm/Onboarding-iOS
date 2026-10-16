//
//  RevenueCatPlanMappingTests.swift
//  onboarding-ios
//

import Foundation
import RevenueCat
import Testing
@testable import Paywalls
@testable import PaywallsRC

/// How RevenueCat's packages become the paywall's plans. The trial length drives the CTA ("Try 3
/// Days Free") and the timeline's dates, so only a free introductory offer may count as one.
@MainActor
struct RevenueCatPlanMappingTests {

    private func package(
        _ type: PackageType,
        id: String = "package",
        price: String = "29.99",
        intro: TestStoreProductDiscount? = nil
    ) -> Package {
        let product = TestStoreProduct(
            localizedTitle: "Pretzly Premium",
            price: Decimal(string: price) ?? 0,
            currencyCode: "EUR",
            localizedPriceString: "€\(price)",
            productIdentifier: "premium.\(id)",
            productType: .autoRenewableSubscription,
            localizedDescription: "All of it",
            subscriptionPeriod: SubscriptionPeriod(value: 1, unit: .year),
            introductoryDiscount: intro,
            locale: Locale(identifier: "de_DE")
        )
        return Package(
            identifier: id,
            packageType: type,
            storeProduct: product.toStoreProduct(),
            offeringIdentifier: "onboarding",
            webCheckoutUrl: nil
        )
    }

    private func intro(_ mode: StoreProductDiscount.PaymentMode, _ value: Int, _ unit: SubscriptionPeriod.Unit) -> TestStoreProductDiscount {
        TestStoreProductDiscount(
            identifier: "intro",
            price: mode == .freeTrial ? 0 : 0.99,
            localizedPriceString: mode == .freeTrial ? "€0" : "€0.99",
            paymentMode: mode,
            subscriptionPeriod: SubscriptionPeriod(value: value, unit: unit),
            numberOfPeriods: 1,
            type: .introductory
        )
    }

    @Test func test_plan_thenCarriesThePackagesPriceAndIdentity() throws {
        let plan = try #require(RevenueCatPaywallService.plan(from: package(.annual, id: "$rc_annual", price: "29.99")))

        #expect(plan.id == "$rc_annual")
        #expect(plan.period == .yearly)
        #expect(plan.price == 29.99)
        #expect(plan.localizedPrice == "€29.99")
        #expect(plan.localizedTitle == "Pretzly Premium")
    }

    @Test func test_plan_thenMapsEachCadenceTheTilesKnow() {
        let periods = [PackageType.weekly, .monthly, .annual, .lifetime].map {
            RevenueCatPaywallService.plan(from: package($0))?.period
        }

        #expect(periods == [.weekly, .monthly, .yearly, .lifetime])
    }

    /// The savings maths compares prices per day, which needs a cadence the paywall knows.
    @Test(arguments: [PackageType.twoMonth, .threeMonth, .sixMonth, .custom, .unknown])
    func test_plan_whenTheCadenceIsUnknownToThePaywall_thenDropped(type: PackageType) {
        #expect(RevenueCatPaywallService.plan(from: package(type)) == nil)
    }

    @Test func test_freeTrialDays_whenAFreeIntro_thenItsLengthInDays() {
        let lengths = [
            intro(.freeTrial, 3, .day),
            intro(.freeTrial, 1, .week),
            intro(.freeTrial, 1, .month),
        ].map { RevenueCatPaywallService.plan(from: package(.annual, intro: $0))?.freeTrialDays }

        #expect(lengths == [3, 7, 30])
    }

    /// A cheaper first period is a discount, not a trial: calling it one would promise the user a
    /// free start and date the first charge wrongly.
    @Test(arguments: [StoreProductDiscount.PaymentMode.payAsYouGo, .payUpFront])
    func test_freeTrialDays_whenThePaidIntro_thenNoTrial(mode: StoreProductDiscount.PaymentMode) {
        let plan = RevenueCatPaywallService.plan(from: package(.annual, intro: intro(mode, 1, .month)))

        #expect(plan?.freeTrialDays == nil)
        #expect(plan?.hasFreeTrial == false)
    }

    @Test func test_freeTrialDays_whenNoIntro_thenNoTrial() {
        #expect(RevenueCatPaywallService.plan(from: package(.annual))?.freeTrialDays == nil)
    }
}
