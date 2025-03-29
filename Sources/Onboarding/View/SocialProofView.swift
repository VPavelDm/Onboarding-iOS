import SwiftUI

struct SocialProofView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let step: SocialProofStep

    var body: some View {
        VStack(spacing: 32) {
            imageView
            palmBranchView
            titleView
            reviewView
            Spacer()
            nextButton
        }
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(BottomWaveShape())
        }
    }

    private var palmBranchView: some View {
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
            .frame(height: 75)
            .foregroundStyle(viewModel.colorPalette.textColor)
    }

    private var laurelTitleView: some View {
        Text(step.palmBranchTitle)
            .font(.title.bold())
            .foregroundStyle(viewModel.colorPalette.textColor)
    }

    private var laurelDescriptionView: some View {
        Text(step.palmBranchDescription)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 64)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var reviewView: some View {
        VStack(spacing: 8) {
            reviewStarsView
            reviewTitleView
        }
    }

    private var reviewStarsView: some View {
        HStack {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .foregroundStyle(viewModel.colorPalette.textColor)
            }
        }
    }

    private var reviewTitleView: some View {
        Text(step.userReview)
            .font(.headline)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
    }

    private var nextButton: some View {
        Button {} label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    OnboardingView(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(),
        colorPalette: .testData,
        outerScreen: { _ in
        }
    )
    .preferredColorScheme(.dark)
}
