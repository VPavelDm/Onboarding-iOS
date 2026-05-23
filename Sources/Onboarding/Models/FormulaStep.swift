import Foundation

struct FormulaStep: Sendable, Equatable, Hashable {
    var operandLeftNumber: String
    var operandRightNumber: String
    var resultNumber: String
    var detailRows: [DetailRow]
    var nextStepID: StepID?

    struct DetailRow: Sendable, Equatable, Hashable {
        var label: String
        var value: String
    }
}

extension FormulaStep {

    init(response: OnboardingStepResponse.FormulaStep, localizer: Localizer) {
        self.init(
            operandLeftNumber: response.operandLeftNumber,
            operandRightNumber: response.operandRightNumber,
            resultNumber: response.resultNumber,
            detailRows: response.detailRows.map {
                DetailRow(
                    label: $0.label.localized(using: localizer),
                    value: $0.value.localized(using: localizer)
                )
            },
            nextStepID: response.nextStepID
        )
    }
}
