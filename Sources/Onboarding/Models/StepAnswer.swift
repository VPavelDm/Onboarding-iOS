//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 08.09.24.
//

import Foundation

struct StepAnswer: Sendable, Equatable, Hashable {
    var title: String
    var icon: String?
    var nextStepID: StepID?
    var payload: Payload?

    enum Payload: Sendable, Equatable, Hashable {
        case string(String)
        case json(Data)

        var string: String? {
            switch self {
            case .string(let string):
                return string
            case .json:
                return nil
            }
        }

        var data: Data? {
            switch self {
            case .string:
                return nil
            case .json(let data):
                return data
            }
        }
    }
}

// MARK: - Convert

extension StepAnswer {

    init(response: OnboardingStepResponse.StepAnswer) {
        self.init(
            title: response.title,
            icon: response.icon,
            nextStepID: response.nextStepID,
            payload: response.payload.map(Payload.init(response:))
        )
    }
}

extension StepAnswer.Payload {
    
    init(response: OnboardingStepResponse.StepAnswer.Payload) {
        switch response {
        case .string(let string):
            self = .string(string)
        case .json(let data):
            self = .json(data)
        }
    }
}
