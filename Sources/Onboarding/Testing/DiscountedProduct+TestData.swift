//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import Foundation

extension DiscountedProduct {

    static func testData(
        expirationDate: Date = Date.now.advanced(by: -86400)
    ) -> Self {
        DiscountedProduct(
            duration: "12 months",
            discountedPrice: "35,99$",
            originalPrice: "119,99$",
            monthlyPrice: "2,99$",
            monthlyPriceTitle: "/month",
            termsOfUse: URL(string: "https://google.com")!,
            privacyPolicy: URL(string: "https://google.com")!,
            discount: Discount(expirationDate: expirationDate)
        )
    }
}
