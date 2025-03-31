import SwiftUI

struct SocialProofView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let step: SocialProofStep

    var body: some View {
        VStack {
            imageView
            Spacer()
            VStack(spacing: 64) {
                laurelsView
                titleView
                reviewView
            }
            Spacer()
            Spacer()
            nextButton
        }
        .ignoresSafeArea(edges: .top)
        .padding(.top, .progressBarHeight + .progressBarBottomPadding)
//        .background(viewModel.colorPalette.backgroundColor)
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .foregroundStyle(.secondary)
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .clipShape(BottomWaveShape())
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
        Text(step.palmBranchTitle)
            .font(.title.bold())
            .foregroundStyle(viewModel.colorPalette.textColor)
            .applyIf { view in
                if #available(iOS 16.1, *) {
                    view.fontDesign(.rounded)
                }
            }
    }

    private var laurelDescriptionView: some View {
        Text(step.palmBranchDescription)
            .font(.title2)
            .fontWeight(.medium)
            .applyIf { view in
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
            .applyIf { view in
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
            .applyIf { view in
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
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        OnboardingView(
            configuration: .testData(),
            delegate: MockOnboardingDelegate(),
            colorPalette: .testData,
            outerScreen: { _ in
            }
        )
        .preferredColorScheme(.dark)
        .background(AffirmationBackgroundView())
    }
}
