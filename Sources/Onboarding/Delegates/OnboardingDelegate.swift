//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import Foundation

public protocol OnboardingDelegate {
    
    func processAnswers(_ answers: [UserAnswer]) async throws
    func setupNotifications(for time: String) async throws
    func finalise() async
}
