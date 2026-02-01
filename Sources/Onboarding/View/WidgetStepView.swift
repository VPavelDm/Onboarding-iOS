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
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    var descriptionView: some View {
        Text(step.description)
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
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}
