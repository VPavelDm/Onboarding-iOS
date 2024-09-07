//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import Foundation

struct OnboardingStepResponse: Decodable {
    let id: UUID
    let nextStepID: UUID?
    let type: OnboardingStepType
    let maxStepsInChain: Int

    enum CodingKeys: String, CodingKey {
        case id
        case nextStepID
        case type
        case maxStepsInChain
        case payload
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        nextStepID = try container.decodeIfPresent(UUID.self, forKey: .nextStepID)
        maxStepsInChain = try container.decode(Int.self, forKey: .maxStepsInChain)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "multipleAnswer":
            let payload = try container.decode(MultipleAnswerStep.self, forKey: .payload)
            self.type = .multipleAnswer(payload)
        case "oneAnswer":
            let payload = try container.decode(OneAnswerStep.self, forKey: .payload)
            self.type = .oneAnswer(payload)
        case "binaryAnswer":
            let payload = try container.decode(BinaryAnswer.self, forKey: .payload)
            self.type = .binaryAnswer(payload)
        case "description":
            let payload = try container.decode(DescriptionStep.self, forKey: .payload)
            self.type = .description(payload)
        case "login":
            self.type = .login
        case "custom":
            self.type = .custom
        case "prime":
            self.type = .prime
        default:
            self.type = .unknown
        }
    }

    enum OnboardingStepType {
        case oneAnswer(OneAnswerStep)
        case multipleAnswer(MultipleAnswerStep)
        case description(DescriptionStep)
        case binaryAnswer(BinaryAnswer)
        case login
        case custom
        case prime
        case unknown
    }

    struct OneAnswerStep: Decodable {
        let title: String
        let description: String?
        let answers: [String]
    }

    struct MultipleAnswerStep: Decodable {
        let title: String
        let description: String?
        let answers: [String]
    }

    struct DescriptionStep: Decodable {
        let title: String
        let image: ImageResponse?
        let description: String?
    }

    struct ImageResponse: Decodable {
        let type: String
        let value: String
    }

    struct BinaryAnswer: Decodable {
        let title: String
        let description: String?
        let firstAnswer: Answer
        let secondAnswer: Answer

        struct Answer: Decodable {
            let text: String
            let icon: String?
        }
    }
}
