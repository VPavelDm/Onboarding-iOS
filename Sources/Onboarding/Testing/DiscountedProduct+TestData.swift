//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import Foundation

extension DiscountedProduct {

    static func testData() -> Self {
        DiscountedProduct(
            duration: "12 months",
            discountedPrice: "35,99$",
            originalPrice: "119,99$",
            monthlyPrice: "2,99$",
            monthlyPriceTitle: "/month"
        )
    }
}
