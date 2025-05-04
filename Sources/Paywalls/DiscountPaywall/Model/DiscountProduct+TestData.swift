//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.03.25.
//

import Foundation

extension DiscountProduct {

    static func testData(
        expirationDate: Date = Date.now.advanced(by: -86400)
    ) -> Self {
        DiscountProduct(
            duration: "12 months",
            discountedPrice: "35,99$",
            originalAnnualPrice: "119,99$",
            originalMonthlyPrice: "9,99$",
            monthlyPrice: "2,99$",
            monthlyPriceTitle: "/month",
            termsOfUse: URL(string: "https://google.com")!,
            privacyPolicy: URL(string: "https://google.com")!,
            discount: Discount(expirationDate: expirationDate)
        )
    }
}
