//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import Foundation

@MainActor
public protocol OnboardingDelegate {
    
    func processAnswers(_ answers: [UserAnswer]) async throws
    func setupNotifications(for time: String) async throws
    func fetchDiscountedProduct() async throws -> DiscountedProduct
    func makePurchase(_ product: DiscountedProduct) async throws
    func format(string: String) -> String
    func finalise() async

    func onAnswerClick(userAnswer: UserAnswer) async
    func onBackButtonClick() async
}

public extension OnboardingDelegate {

    func format(string: String) -> String {
        string
    }
}
