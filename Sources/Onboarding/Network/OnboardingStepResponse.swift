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
        case "featureShowcase":
            let payload = try container.decode(FeatureShowcaseStep.self, forKey: .payload)
            self.type = .featureShowcase(payload)
        case "intro":
            let payload = try container.decode(IntroStep.self, forKey: .payload)
            self.type = .intro(payload)
        case "enterValue":
            let payload = try container.decode(EnterValueStep.self, forKey: .payload)
            self.type = .enterValue(payload)
        case "heightPicker":
            let payload = try container.decode(HeightPickerStep.self, forKey: .payload)
            self.type = .heightPicker(payload)
        case "weightPicker":
            let payload = try container.decode(WeightPickerStep.self, forKey: .payload)
            self.type = .weightPicker(payload)
        case "agePicker":
            let payload = try container.decode(AgePickerStep.self, forKey: .payload)
            self.type = .agePicker(payload)
        case "custom":
            let payload = try container.decodeIfPresent(CustomStep.self, forKey: .payload)
            self.type = .custom(payload)
        case "survivalFunnel":
            let payload = try container.decode(SurvivalFunnelStep.self, forKey: .payload)
            self.type = .survivalFunnel(payload)
        case "floatingWords":
            let payload = try container.decode(FloatingWordsStep.self, forKey: .payload)
            self.type = .floatingWords(payload)
        case "commitmentHold":
            let payload = try container.decode(CommitmentHoldStep.self, forKey: .payload)
            self.type = .commitmentHold(payload)
        case "receipt":
            let payload = try container.decode(ReceiptStep.self, forKey: .payload)
            self.type = .receipt(payload)
        case "formula":
            let payload = try container.decode(FormulaStep.self, forKey: .payload)
            self.type = .formula(payload)
        case "progressBars":
            let payload = try container.decode(ProgressBarsStep.self, forKey: .payload)
            self.type = .progressBars(payload)
        case "milestoneTimeline":
            let payload = try container.decode(MilestoneTimelineStep.self, forKey: .payload)
            self.type = .milestoneTimeline(payload)
        case "comparisonCards":
            let payload = try container.decode(ComparisonCardsStep.self, forKey: .payload)
            self.type = .comparisonCards(payload)
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
        case featureShowcase(FeatureShowcaseStep)
        case intro(IntroStep)
        case enterValue(EnterValueStep)
        case heightPicker(HeightPickerStep)
        case weightPicker(WeightPickerStep)
        case agePicker(AgePickerStep)
        case custom(CustomStep?)
        case survivalFunnel(SurvivalFunnelStep)
        case floatingWords(FloatingWordsStep)
        case commitmentHold(CommitmentHoldStep)
        case receipt(ReceiptStep)
        case formula(FormulaStep)
        case progressBars(ProgressBarsStep)
        case milestoneTimeline(MilestoneTimelineStep)
        case comparisonCards(ComparisonCardsStep)
        case unknown
    }

    struct OneAnswerStep: Decodable {
        let title: String
        let description: String?
        let image: ImageResponse?
        let buttonTitle: String
        let skip: StepAnswer?
        let answers: [StepAnswer]
        let autoNavigateOnSingleAnswer: Bool?
    }

    struct MultipleAnswerStep: Decodable {
        let title: String
        let description: String?
        let image: ImageResponse?
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

    struct CommitmentHoldStep: Decodable {
        let title: String
        let subtitle: String?
        let commitmentPrefix: String?
        let commitmentNumber: String
        let commitmentSuffix: String?
        let commitmentFooter: String?
        let answer: StepAnswer
    }

    struct ReceiptStep: Decodable {
        let items: [String]
        let nextStepID: StepID?
    }

    struct FormulaStep: Decodable {
        let title: String
        let subtitle: String?
        let operandLeft: Operand
        let operandSymbol: String
        let operandRight: Operand
        let result: Operand
        let detailRows: [DetailRow]
        let answer: StepAnswer

        struct Operand: Decodable {
            let number: String
            let label: String
        }

        struct DetailRow: Decodable {
            let label: String
            let value: String
        }
    }

    struct ProgressBarsStep: Decodable {
        let title: String
        let stepLabels: [String]
        let creditNumber: String?
        let creditDescription: [String]
        let answer: StepAnswer
    }

    struct MilestoneTimelineStep: Decodable {
        let title: String
        let subtitle: String?
        let floatingLabel: String?
        let milestones: [Milestone]
        let answer: StepAnswer

        struct Milestone: Decodable {
            let label: String
            let xRatio: Double
            let delay: Double
        }
    }

    struct ComparisonCardsStep: Decodable {
        let title: String
        let subtitle: String?
        let leftCard: Card
        let rightCard: Card
        let highlightedIndex: Int?
        let answer: StepAnswer

        struct Card: Decodable {
            let label: String
            let items: [String]
        }
    }

    struct EnterValueStep: Decodable {
        let title: String
        let description: String?
        let image: ImageResponse?
        let placeholder: String
        let valueType: String
        let primaryAnswer: StepAnswer
        let skipAnswer: StepAnswer?
    }

    struct HeightPickerStep: Decodable {
        let title: String
        let description: String?
        let metricUnit: String
        let imperialUnit: String
        let answer: StepAnswer
    }

    struct WeightPickerStep: Decodable {
        let title: String
        let description: String?
        let metricUnit: String
        let imperialUnit: String
        let answer: StepAnswer
    }

    struct AgePickerStep: Decodable {
        let title: String
        let description: String?
        let unit: String
        let answer: StepAnswer
    }

    struct WidgetStep: Decodable {
        let title: String
        let description: String
        let image: ImageResponse?
        let answer: StepAnswer
    }

    struct FeatureShowcaseStep: Decodable {
        let title: String
        let image: ImageResponse
        let description: String?
        let backgroundColor: String
        let answer: StepAnswer
    }

    struct IntroStep: Decodable {
        let title: String
        let subtitle: String?
        let description: String?
        let image: ImageResponse
        let accentColor: String?
        let answer: StepAnswer
    }

    struct SocialProofStep: Decodable {
        let image: ImageResponse
        let welcomeHeadline: String
        let welcomeSubheadline: String
        let userReview: String
        let stats: [StatItem]?
        let message: String
        let messageAuthor: String?
        let answer: StepAnswer
    }

    struct StatItem: Decodable {
        let value: String
        let label: String
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
        let branches: [String: StepID]?
    }

    struct SurvivalFunnelStep: Decodable {
        let title: String
        let description: String?
        let caption: String?
        let stages: [Stage]
        let answer: StepAnswer

        struct Stage: Decodable {
            let label: String
            let count: Int
            let dropoffLabel: String?
        }
    }

    struct FloatingWordsStep: Decodable {
        let title: String
        let description: String?
        let caption: String?
        let centralWord: String
        let centralTranslation: String?
        let floatingWords: [String]
        let answer: StepAnswer
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
