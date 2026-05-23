import Foundation

struct WidgetStep: Sendable, Equatable, Hashable {
    let image: ImageMeta?
    let nextStepID: StepID?
}

// MARK: - Convert

extension WidgetStep {

    init(response: OnboardingStepResponse.WidgetStep, localizer: Localizer) {
        var image: ImageMeta?
        if let imageResponse = response.image {
            image = ImageMeta(response: imageResponse)
        }
        self.init(
            image: image,
            nextStepID: response.nextStepID
        )
    }
}
