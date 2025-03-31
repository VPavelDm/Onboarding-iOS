//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import Foundation

final class MockOnboardingDelegate: OnboardingDelegate {
    var onAnswerCallback: () -> Void

    init(onAnswerCallback: @escaping () -> Void) {
        self.onAnswerCallback = onAnswerCallback
    }

    func setupNotifications(for time: String) async throws {
    }
    func onAnswer(userAnswer: UserAnswer, allAnswers: [UserAnswer]) {
        onAnswerCallback()
    }
}
