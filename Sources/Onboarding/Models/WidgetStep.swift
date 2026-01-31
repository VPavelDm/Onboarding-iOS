import Foundation

struct WidgetStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String
    let image: ImageMeta?
    let answer: StepAnswer
}

// MARK: - Convert

extension WidgetStep {

    init(response: OnboardingStepResponse.WidgetStep, localizer: Localizer) {
        var image: ImageMeta?
        if let imageResponse = response.image {
            image = ImageMeta(response: imageResponse)
        }
        self.init(
            title: response.title.localized(using: localizer),
            description: response.description.localized(using: localizer),
            image: image,
            answer: StepAnswer(response: response.answer, localizer: localizer)
        )
    }
}
