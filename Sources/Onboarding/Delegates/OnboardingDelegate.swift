//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import Foundation

@MainActor
public protocol OnboardingDelegate {
    
    func setupNotifications(for time: String) async throws
    func format(string: String) -> String
    func onAnswerClick(userAnswer: UserAnswer, allAnswers: [UserAnswer]) async
}

public extension OnboardingDelegate {

    func format(string: String) -> String {
        string
    }
}
