import SwiftUI

struct WidgetStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let step: WidgetStep

    var body: some View {
        VStack {
            titleView
            descriptionView
            iPhoneImageView
                .frame(maxHeight: .infinity)
            installWidgetButton
            remindLaterButton
        }
        .padding()
        .padding(.top, .progressBarHeight + .progressBarBottomPadding)
        .background(viewModel.colorPalette.backgroundColor)
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
            .font(.headline)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    var iPhoneImageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .aspectRatio(1.0, contentMode: image.contentMode)
        }
    }

    var installWidgetButton: some View {
        Button {
            if let url = URL(string: "app-prefs:") {
                UIApplication.shared.open(url)
            }
        } label: {
            Text(step.installWidgetAnswer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    var remindLaterButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.remindLaterAnswer])
        } label: {
            Text(step.remindLaterAnswer.title)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

#Preview {
    WidgetStepView(step: .testData)
        .environmentObject(OnboardingViewModel(
            configuration: .testData(),
            delegate: MockOnboardingDelegate(),
            colorPalette: .testData
        ))
        .preferredColorScheme(.dark)
}
