import SwiftUI

struct SocialProofView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let step: SocialProofStep

    var body: some View {
        VStack {
            imageView
            VStack(spacing: 64) {
                laurelsView
                titleView
                reviewView
            }
            .frame(maxHeight: .infinity)
            Spacer()
            nextButton
        }
        .padding()
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
        }
    }

    private var laurelsView: some View {
        HStack {
            laurelView
            VStack {
                laurelTitleView
                laurelDescriptionView
            }
            laurelView
                .scaleEffect(x: -1, y: 1)
        }
    }

    private var laurelView: some View {
        Image("laurel", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 52)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
    }

    private var laurelTitleView: some View {
        Text(step.laurelTitle)
            .font(.title.bold())
            .foregroundStyle(viewModel.colorPalette.textColor)
            .apply { view in
                if #available(iOS 16.1, *) {
                    view.fontDesign(.rounded)
                }
            }
    }

    private var laurelDescriptionView: some View {
        Text(step.laurelDescription)
            .font(.title2)
            .fontWeight(.medium)
            .apply { view in
                if #available(iOS 16.1, *) {
                    view.fontDesign(.rounded)
                }
            }
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title3)
            .fontWeight(.medium)
            .apply { view in
                if #available(iOS 16.1, *) {
                    view.fontDesign(.rounded)
                }
            }
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 64)
    }

    private var reviewView: some View {
        VStack(spacing: 8) {
            reviewStarsView
            reviewTitleView
        }
    }

    private var reviewStarsView: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.callout)
                    .foregroundStyle(viewModel.colorPalette.textColor)
            }
        }
    }

    private var reviewTitleView: some View {
        Text(step.userReview)
            .font(.headline)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
            .apply { view in
                if #available(iOS 16.1, *) {
                    view.fontDesign(.rounded)
                }
            }
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

#Preview {
    MockOnboardingView()
}
