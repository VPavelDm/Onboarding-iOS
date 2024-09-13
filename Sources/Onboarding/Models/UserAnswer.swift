//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 07.09.24.
//

import Foundation

public struct UserAnswer: Sendable, Equatable, Hashable {
    public var onboardingStepID: UUID
    public var answers: [String]
}
