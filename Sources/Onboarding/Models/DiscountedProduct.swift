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
    var originalPrice: String
    var monthlyPrice: String
    var monthlyPriceTitle: String
    var termsOfUse: URL
    var privacyPolicy: URL
    var discount: Discount

    public init(
        duration: String,
        discountedPrice: String,
        originalPrice: String,
        monthlyPrice: String,
        monthlyPriceTitle: String,
        termsOfUse: URL,
        privacyPolicy: URL,
        discount: Discount
    ) {
        self.duration = duration
        self.discountedPrice = discountedPrice
        self.originalPrice = originalPrice
        self.monthlyPrice = monthlyPrice
        self.monthlyPriceTitle = monthlyPriceTitle
        self.termsOfUse = termsOfUse
        self.privacyPolicy = privacyPolicy
        self.discount = discount
    }
}

// MARK: - Discount

extension DiscountedProduct {

    public struct Discount: Sendable, Equatable, Hashable {
        public var expirationDate: Date

        public init(expirationDate: Date) {
            self.expirationDate = expirationDate
        }
    }
}
