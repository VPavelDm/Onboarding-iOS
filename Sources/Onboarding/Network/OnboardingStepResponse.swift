//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import Foundation

struct OnboardingStepResponse: Decodable {
    let id: StepID
    let type: OnboardingStepType
    let passedPercent: Double

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case passedPercent
        case payload
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(StepID.self, forKey: .id)
        passedPercent = try container.decode(Double.self, forKey: .passedPercent)
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
            let payload = try container.decode(CustomStep.self, forKey: .payload)
            self.type = .login(payload.answer)
        case "custom":
            let payload = try container.decode(CustomStep.self, forKey: .payload)
            self.type = .custom(payload.answer)
        case "prime":
            let payload = try container.decode(CustomStep.self, forKey: .payload)
            self.type = .prime(payload.answer)
        case "welcome":
            let payload = try container.decode(WelcomeStep.self, forKey: .payload)
            self.type = .welcome(payload)
        case "progress":
            let payload = try container.decode(ProgressStep.self, forKey: .payload)
            self.type = .progress(payload)
        case "timePicker":
            let payload = try container.decode(TimePickerStep.self, forKey: .payload)
            self.type = .timePicker(payload)
        case "discountWheel":
            let payload = try container.decode(DiscountWheelStep.self, forKey: .payload)
            self.type = .discountWheel(payload)
        default:
            self.type = .unknown
        }
    }

    enum OnboardingStepType {
        case oneAnswer(OneAnswerStep)
        case multipleAnswer(MultipleAnswerStep)
        case description(DescriptionStep)
        case binaryAnswer(BinaryAnswer)
        case login(StepAnswer)
        case custom(StepAnswer)
        case prime(StepAnswer)
        case welcome(WelcomeStep)
        case progress(ProgressStep)
        case timePicker(TimePickerStep)
        case discountWheel(DiscountWheelStep)
        case unknown
    }

    struct OneAnswerStep: Decodable {
        let title: String
        let description: String?
        let answers: [StepAnswer]
    }

    struct MultipleAnswerStep: Decodable {
        let title: String
        let description: String?
        let buttonTitle: String
        let answers: [StepAnswer]
    }

    struct DescriptionStep: Decodable {
        let title: String
        let image: ImageResponse?
        let description: String?
        let answer: StepAnswer
    }

    struct ImageResponse: Decodable {
        let type: String
        let value: String
    }

    struct BinaryAnswer: Decodable {
        let title: String
        let description: String?
        let firstAnswer: StepAnswer
        let secondAnswer: StepAnswer
    }

    struct WelcomeStep: Decodable {
        let title: String
        let description: String
        let emojis: [String]
        let firstAnswer: StepAnswer
        let secondAnswer: StepAnswer?
    }

    struct ProgressStep: Decodable {
        let title: String
        let steps: [String]
        let answer: StepAnswer
    }

    struct TimePickerStep: Decodable {
        let title: String
        let answer: StepAnswer
    }

    struct DiscountWheelStep: Decodable {
        let title: String
    }

    struct StepAnswer: Decodable {
        let title: String
        let icon: String?
        let nextStepID: StepID?
        let payload: Payload?

        enum Payload: Decodable {
            case string(String)
            case json(Data)

            enum CodingKeys: String, CodingKey {
                case type
                case value
            }

            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(String.self, forKey: .type)
                switch type {
                case "string":
                    self = .string(try container.decode(String.self, forKey: .value))
                case "json":
                    self = .json(try container.decode(Data.self, forKey: .value))
                default:
                    throw DecodingError.dataCorrupted(DecodingError.Context(
                        codingPath: [CodingKeys.value],
                        debugDescription: ""
                    ))
                }
            }
        }
    }

    struct CustomStep: Decodable {
        let answer: StepAnswer
    }
}
