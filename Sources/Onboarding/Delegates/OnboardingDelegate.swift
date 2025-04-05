//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import Foundation

@MainActor
public protocol OnboardingDelegate {    
    func format(string: String) -> String
    func onAnswer(userAnswer: UserAnswer, allAnswers: [UserAnswer]) async
}

public extension OnboardingDelegate {

    func format(string: String) -> String {
        string
    }
}
