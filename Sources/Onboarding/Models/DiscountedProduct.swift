//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import Foundation

public struct DiscountedProduct: Sendable, Equatable, Hashable {
    var duration: String
    var discountedPrice: String
    var originalAnnualPrice: String
    var originalMonthlyPrice: String
    var monthlyPrice: String
    var monthlyPriceTitle: String
    var termsOfUse: URL
    var privacyPolicy: URL
    var discount: Discount

    public init(
        duration: String,
        discountedPrice: String,
        originalAnnualPrice: String,
        originalMonthlyPrice: String,
        monthlyPrice: String,
        monthlyPriceTitle: String,
        termsOfUse: URL,
        privacyPolicy: URL,
        discount: Discount
    ) {
        self.duration = duration
        self.discountedPrice = discountedPrice
        self.originalAnnualPrice = originalAnnualPrice
        self.originalMonthlyPrice = originalMonthlyPrice
        self.monthlyPrice = monthlyPrice
        self.monthlyPriceTitle = monthlyPriceTitle
        self.termsOfUse = termsOfUse
        self.privacyPolicy = privacyPolicy
        self.discount = discount
    }
}
