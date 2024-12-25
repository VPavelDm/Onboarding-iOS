//
//  CountdownClockViewModel.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 24.12.24.
//

import SwiftUI
import Combine

public final class CountdownClockViewModel: ObservableObject {

    // MARK: - Public

    @Published public var timeComponents: [TimeComponent] = []

    // MARK: - Private

    private let timer = Timer.publish(every: 1, on: .main, in: .common)
    private var timerCancellation: AnyCancellable?
    private let calendar: Calendar
    private let currentDate: () -> Date
    private let discount: DiscountedProduct.Discount

    // MARK: - Lifecycle

    public init(
        discount: DiscountedProduct.Discount,
        calendar: Calendar = .current,
        currentDate: @escaping () -> Date = { .now }
    ) {
        self.discount = discount
        self.currentDate = currentDate
        self.calendar = calendar
        try? updateRemainingTime()
    }

    // MARK: - Public

    public func startTimer() {
        timerCancellation = timer
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                try? self?.updateRemainingTime()
            }
    }

    // MARK: - Private

    ///  This method prepares `timeComponents: [TimeComponent]` to be displayed in View.
    ///
    ///  `TimeComponent` is a struct that represents how much days, hours or minutes left till campaign expires.
    ///  To prepare `TimeComponent` I calculate remaining time and then combine it with localised label.
    private func updateRemainingTime() throws {
        let components = try calculateRemainingTime()

        let labels: [String] = [
            String(localized: "\(components.days) Days", bundle: .module),
            String(localized: "\(components.hours) Hours", bundle: .module),
            String(localized: "\(components.minutes) Minutes", bundle: .module),
            String(localized: "\(components.seconds) Seconds", bundle: .module)
                .replacing("%d", with: "")
        ]

        timeComponents = zip([components.days, components.hours, components.minutes, components.seconds], labels)
            .map { component, label in
                TimeComponent(
                    digits: String(format: "%02d", component).compactMap({ $0.wholeNumberValue }),
                    label: label
                )
            }
    }

    private func calculateRemainingTime() throws -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let currentDate = currentDate()
        guard currentDate < discount.expirationDate else {
            throw CampaignExpiredError()
        }

        let dateComponents = calendar.dateComponents(
            [.day, .hour, .minute, .second],
            from: currentDate,
            to: discount.expirationDate
        )
        let days = dateComponents.day ?? 0
        let hours = dateComponents.hour ?? 0
        let minutes = dateComponents.minute ?? 0
        let seconds = dateComponents.second ?? 0

        return (days, hours, minutes, seconds)
    }

    // MARK: -

    public struct TimeComponent: Equatable {
        public var digits: [Int]
        public var label: String
    }

    private struct CampaignExpiredError: Error {}
}

#Preview {
    PrimeStepView(step: .testData())
        .environmentObject(OnboardingViewModel(
            configuration: .testData(),
            delegate: MockOnboardingDelegate()
        ))
        .preferredColorScheme(.dark)
}

