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

    public init(
        duration: String,
        discountedPrice: String,
        originalPrice: String,
        monthlyPrice: String,
        monthlyPriceTitle: String
    ) {
        self.duration = duration
        self.discountedPrice = discountedPrice
        self.originalPrice = originalPrice
        self.monthlyPrice = monthlyPrice
        self.monthlyPriceTitle = monthlyPriceTitle
    }
}
