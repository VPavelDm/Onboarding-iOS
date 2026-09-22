import Foundation

/// Asks for notification permission by showing what the notifications will look like. The banners
/// carry the app's own copy, so the step promises exactly what it will send.
struct NotificationsStep: Sendable, Equatable, Hashable {
    let title: String
    let description: String?
    let buttonTitle: String
    /// Shown under the button when the step lets the user move on without granting anything.
    let skip: StepAnswer?
    /// The sender the banners are from, as the system would draw it.
    let appName: String
    let banners: [Banner]
    let nextStepID: StepID?

    struct Banner: Sendable, Equatable, Hashable {
        let title: String
        let body: String
    }
}

// MARK: - Convert

extension NotificationsStep {

    init(response: OnboardingStepResponse.NotificationsStep) {
        self.init(
            title: response.title,
            description: response.description,
            buttonTitle: response.buttonTitle,
            skip: response.skip.map { StepAnswer(response: $0) },
            appName: response.appName,
            banners: response.banners.map { Banner(title: $0.title, body: $0.body) },
            nextStepID: response.nextStepID
        )
    }
}
