import SwiftUI
import CoreUI

struct WidgetStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let step: WidgetStep

    var body: some View {
        VStack {
            titleView
            descriptionView
            iPhoneImageView
                .frame(maxHeight: .infinity)
            continueButton
        }
        .padding()
    }

    var titleView: some View {
        Text(localized("widget.title"))
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    var descriptionView: some View {
        Text(localized("widget.description"))
            .font(.body)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var iPhoneImageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .aspectRatio(1.0, contentMode: image.contentMode)
                .padding(.horizontal)
        }
    }

    var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [makeAnswer()])
        } label: {
            Text(localized("widget.answerTitle"))
        }
        .buttonStyle(SecondaryButtonStyle())
    }

    private func localized(_ key: String) -> String {
        viewModel.localizer.localize(key)
    }

    private func makeAnswer() -> StepAnswer {
        StepAnswer(
            title: localized("widget.answerTitle"),
            icon: nil,
            nextStepID: step.nextStepID,
            payload: nil
        )
    }
}
