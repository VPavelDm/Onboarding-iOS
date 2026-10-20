//
//  OfferPitchTests.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation
import Testing
@testable import Paywalls

struct OfferPitchTests {

    private let us = Locale(identifier: "en_US")

    private func plan(_ period: PaywallPlan.Period, _ price: Double, _ label: String, locale: Locale? = nil) -> PaywallPlan {
        PaywallPlan(id: "p-\(label)", period: period, price: price, localizedPrice: label, freeTrialDays: nil, priceLocale: locale ?? us)
    }

    @Test func regularPrice_isTwiceThePriceAtNinetyNineCents() {
        #expect(OfferPitch.regularPrice(of: plan(.yearly, 29.99, "$29.99")) == 59.99)
        #expect(OfferPitch.regularPrice(of: plan(.weekly, 2.49, "$2.49")) == 4.99)
    }

    @Test func regularPrice_doublesPlainly_whenTheCurrencyHasNoCents() {
        let yen = plan(.yearly, 4500, "¥4,500", locale: Locale(identifier: "ja_JP"))
        #expect(OfferPitch.regularPrice(of: yen) == 9000)
    }

    @Test func regularPrice_doublesPlainly_withoutAStorefrontLocale() {
        let bare = PaywallPlan(id: "p", period: .yearly, price: 29.99, localizedPrice: "$29.99", freeTrialDays: nil)
        #expect(OfferPitch.regularPrice(of: bare) == 59.98)
    }

    @Test func percentOff_isFifty_forHalfTheRegularPrice() {
        #expect(OfferPitch.percentOff(plan(.yearly, 29.99, "$29.99")) == 50)
    }

    @Test func pricePerDayCeiling_roundsUpToTheCent() {
        #expect(OfferPitch.pricePerDayCeiling(plan(.yearly, 29.99, "$29.99")) == 0.09)
        #expect(OfferPitch.pricePerDayCeiling(plan(.weekly, 1.99, "$1.99")) == 0.29)
        #expect(OfferPitch.pricePerDayCeiling(plan(.monthly, 8.99, "$8.99")) == 0.30)
    }

    @Test func pricePerDayCeiling_isNil_forLifetime() {
        #expect(OfferPitch.pricePerDayCeiling(plan(.lifetime, 99.99, "$99.99")) == nil)
    }

    @Test func format_usesThePlansCurrency() {
        #expect(OfferPitch.format(59.99, like: plan(.yearly, 29.99, "$29.99")) == "$59.99")
        #expect(OfferPitch.format(9000, like: plan(.yearly, 4500, "¥4,500", locale: Locale(identifier: "ja_JP"))) == "¥9,000")
    }

    @Test func productID_namesThePlanOfTheReportedCadence() {
        let plans = [plan(.weekly, 5.99, "$5.99"), plan(.yearly, 29.99, "$29.99")]

        #expect(OfferPitch.productID(forCadence: "yearly", in: plans) == "p-$29.99")
        #expect(OfferPitch.productID(forCadence: "monthly", in: plans) == nil)
        #expect(OfferPitch.productID(forCadence: "yearly", in: nil) == nil)
        #expect(OfferPitch.analyticsName(.lifetime) == "lifetime")
    }
}
