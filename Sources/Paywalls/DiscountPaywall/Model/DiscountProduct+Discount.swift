//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.03.25.
//

import SwiftUI
import Combine

// MARK: - Discount

public extension DiscountProduct {

    struct Discount: Sendable, Equatable, Hashable {
        public var expirationDate: Date

        public init(expirationDate: Date) {
            self.expirationDate = expirationDate
        }
    }

    struct TimeComponent: Equatable {
        var digits: [Int]
        var label: String
    }
}

extension DiscountProduct.Discount {

    var timeComponents: [DiscountProduct.TimeComponent] {
        let components = calculateRemainingTime()

        let labels: [String] = [
            String(localized: "\(components.days) Days", bundle: .module),
            String(localized: "\(components.hours) Hours", bundle: .module),
            String(localized: "\(components.minutes) Minutes", bundle: .module),
            String(localized: "\(components.seconds) Seconds", bundle: .module)
        ].map { string in
            string.replacing(.localizedInteger(locale: .current), with: "")
        }

        return zip([components.days, components.hours, components.minutes, components.seconds], labels)
            .map { component, label in
                DiscountProduct.TimeComponent(
                    digits: String(format: "%02d", component).compactMap({ $0.wholeNumberValue }),
                    label: label
                )
            }
    }

    private func calculateRemainingTime() -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let calendar = Calendar.current

        guard Date.now <= expirationDate else {
            return (0, 0, 0, 0)
        }

        let dateComponents = calendar.dateComponents(
            [.day, .hour, .minute, .second],
            from: .now,
            to: expirationDate
        )
        let days = dateComponents.day ?? 0
        let hours = dateComponents.hour ?? 0
        let minutes = dateComponents.minute ?? 0
        let seconds = dateComponents.second ?? 0

        return (days, hours, minutes, seconds)
    }
}
