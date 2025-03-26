import Foundation

struct WidgetStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String
    let image: ImageMeta?
    let installWidgetAnswer: StepAnswer
    let remindLaterAnswer: StepAnswer
}

// MARK: - Convert

extension WidgetStep {

    init(response: OnboardingStepResponse.WidgetStep) {
        var image: ImageMeta?
        if let imageResponse = response.image {
            image = ImageMeta(response: imageResponse)
        }
        self.init(
            title: response.title,
            description: response.description,
            image: image,
            installWidgetAnswer: StepAnswer(response: response.installWidgetAnswer),
            remindLaterAnswer: StepAnswer(response: response.remindLaterAnswer)
        )
    }
}
