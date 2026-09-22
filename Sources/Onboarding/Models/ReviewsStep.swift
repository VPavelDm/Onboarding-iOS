import Foundation

/// A wall of reviews under the score they average to: what other people said, in their own words,
/// where a single testimonial would read as a slogan.
struct ReviewsStep: Sendable, Equatable, Hashable {
    let title: String
    /// The score itself, as written — a rating is not arithmetic the step should be doing.
    let rating: String
    let ratingCaption: String
    let buttonTitle: String
    let reviews: [Review]
    let nextStepID: StepID?

    struct Review: Sendable, Equatable, Hashable, Identifiable {
        let title: String
        let body: String
        /// A person's name, shown as written rather than localized.
        let author: String

        var id: String { author + title }
    }
}

// MARK: - Convert

extension ReviewsStep {

    init(response: OnboardingStepResponse.ReviewsStep) {
        self.init(
            title: response.title,
            rating: response.rating,
            ratingCaption: response.ratingCaption,
            buttonTitle: response.buttonTitle,
            reviews: response.reviews.map {
                Review(title: $0.title, body: $0.body, author: $0.author)
            },
            nextStepID: response.nextStepID
        )
    }
}
