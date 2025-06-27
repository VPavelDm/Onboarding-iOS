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

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case passedPercent
        case payload
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(StepID.self, forKey: .id)
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
        case "welcome":
            let payload = try container.decode(WelcomeStep.self, forKey: .payload)
            self.type = .welcome(payload)
        case "welcomeFade":
            let payload = try container.decode(WelcomeFadeStep.self, forKey: .payload)
            self.type = .welcomeFade(payload)
        case "progress":
            let payload = try container.decode(ProgressStep.self, forKey: .payload)
            self.type = .progress(payload)
        case "timePicker":
            let payload = try container.decode(TimePickerStep.self, forKey: .payload)
            self.type = .timePicker(payload)
        case "discountWheel":
            let payload = try container.decode(DiscountWheelStep.self, forKey: .payload)
            self.type = .discountWheel(payload)
        case "widget":
            let payload = try container.decode(WidgetStep.self, forKey: .payload)
            self.type = .widget(payload)
        case "socialProof":
            let payload = try container.decode(SocialProofStep.self, forKey: .payload)
            self.type = .socialProof(payload)
        case "enterValue":
            let payload = try container.decode(EnterValueStep.self, forKey: .payload)
            self.type = .enterValue(payload)
        case "custom":
            let payload = try container.decodeIfPresent(CustomStep.self, forKey: .payload)
            self.type = .custom(payload)
        default:
            self.type = .unknown
        }
    }

    enum OnboardingStepType {
        case oneAnswer(OneAnswerStep)
        case multipleAnswer(MultipleAnswerStep)
        case description(DescriptionStep)
        case binaryAnswer(BinaryAnswer)
        case welcome(WelcomeStep)
        case welcomeFade(WelcomeFadeStep)
        case progress(ProgressStep)
        case timePicker(TimePickerStep)
        case discountWheel(DiscountWheelStep)
        case widget(WidgetStep)
        case socialProof(SocialProofStep)
        case enterValue(EnterValueStep)
        case custom(CustomStep?)
        case unknown
    }

    struct OneAnswerStep: Decodable {
        let title: String
        let description: String?
        let buttonTitle: String
        let skip: StepAnswer?
        let answers: [StepAnswer]
    }

    struct MultipleAnswerStep: Decodable {
        let title: String
        let description: String?
        let buttonTitle: String
        let minAnswersAmount: Int
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
        let aspectRatioType: String
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

    struct WelcomeFadeStep: Decodable {
        let messages: [String]
        let delay: Double
    }

    struct ProgressStep: Decodable {
        let title: String
        let description: String?
        let duration: Double
        let steps: [String]
        let answer: StepAnswer
    }

    struct EnterValueStep: Decodable {
        let title: String
        let description: String?
        let placeholder: String
        let valueType: String
        let answer: StepAnswer
    }

    struct WidgetStep: Decodable {
        let title: String
        let description: String
        let image: ImageResponse?
        let answer: StepAnswer
    }

    struct SocialProofStep: Decodable { 
        let image: ImageResponse
        let welcomeText: String
        let userReview: String
        let message: String
        let answer: StepAnswer
    }

    struct TimePickerStep: Decodable {
        let title: String
        let answer: StepAnswer
    }

    struct DiscountWheelStep: Decodable {
        let title: String
        var spinButtonTitle: String
        var spinFootnote: String
        var successTitle: String
        var successDescription: String
        let answer: StepAnswer
    }

    struct CustomStep: Decodable {
        let nextStepID: StepID?
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
}
