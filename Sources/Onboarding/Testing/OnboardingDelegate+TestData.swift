#if !os(Android)
//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import Foundation

final class MockOnboardingDelegate: OnboardingDelegate {
    var onAnswerCallback: () -> Void
    var mockSubscriptionInfo: SubscriptionInfo?

    init(
        onAnswerCallback: @escaping () -> Void,
        subscriptionInfo: SubscriptionInfo? = SubscriptionInfo(trialDays: 3)
    ) {
        self.onAnswerCallback = onAnswerCallback
        self.mockSubscriptionInfo = subscriptionInfo
    }

    func onAnswer(userAnswer: UserAnswer, allAnswers: [UserAnswer]) {
        onAnswerCallback()
    }

    func subscriptionInfo() -> SubscriptionInfo? {
        mockSubscriptionInfo
    }
}
#endif
