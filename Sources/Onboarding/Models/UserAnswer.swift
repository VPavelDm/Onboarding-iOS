//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 07.09.24.
//

import Foundation

public struct UserAnswer: Sendable, Equatable, Hashable {
    public var onboardingStepID: StepID
    public var payloads: [Payload]

    public enum Payload: Sendable, Equatable, Hashable {
        case string(String)
        case json(Data)

        public var string: String? {
            switch self {
            case .string(let string):
                string
            case .json:
                nil
            }
        }

        public var data: Data? {
            switch self {
            case .string:
                nil
            case .json(let data):
                data
            }
        }
    }
}

extension UserAnswer.Payload {

    init(payload: StepAnswer.Payload) {
        switch payload {
        case .string(let string):
            self = .string(string)
        case .json(let data):
            self = .json(data)
        }
    }
}
