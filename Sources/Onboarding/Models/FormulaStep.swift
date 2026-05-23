import Foundation

struct FormulaStep: Sendable, Equatable, Hashable {
    var title: String
    var subtitle: String?
    var operandLeft: Operand
    var operandSymbol: String
    var operandRight: Operand
    var result: Operand
    var detailRows: [DetailRow]
    var answer: StepAnswer

    struct Operand: Sendable, Equatable, Hashable {
        var number: String
        var label: String
    }

    struct DetailRow: Sendable, Equatable, Hashable {
        var label: String
        var value: String
    }
}

extension FormulaStep {

    init(response: OnboardingStepResponse.FormulaStep, localizer: Localizer) {
        self.init(
            title: response.title.localized(using: localizer),
            subtitle: response.subtitle?.localized(using: localizer),
            operandLeft: Operand(
                number: response.operandLeft.number.localized(using: localizer),
                label: response.operandLeft.label.localized(using: localizer)
            ),
            operandSymbol: response.operandSymbol,
            operandRight: Operand(
                number: response.operandRight.number.localized(using: localizer),
                label: response.operandRight.label.localized(using: localizer)
            ),
            result: Operand(
                number: response.result.number.localized(using: localizer),
                label: response.result.label.localized(using: localizer)
            ),
            detailRows: response.detailRows.map {
                DetailRow(
                    label: $0.label.localized(using: localizer),
                    value: $0.value.localized(using: localizer)
                )
            },
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
