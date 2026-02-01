import SwiftUI
import CoreUI

struct SocialProofView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    @State private var showContent = false
    @State private var showStars = false
    @State private var showStats = false
    @State private var showMessage = false
    @State private var showButton = false

    let step: SocialProofStep

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 32) {
                headerSection
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                ratingSection
                    .opacity(showStars ? 1 : 0)
                    .scaleEffect(showStars ? 1 : 0.9)

                statsSection
                    .opacity(showStats ? 1 : 0)
                    .offset(y: showStats ? 0 : 20)

                messageSection
                    .opacity(showMessage ? 1 : 0)
                    .offset(y: showMessage ? 0 : 20)
            }
            .padding(.horizontal, .hScreenPadding)
            Spacer()
            Spacer()
            nextButton
                .padding(.horizontal, .hScreenPadding)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
        }
        .padding(.vertical, .vScreenPadding)
        .task {
            await animateIn()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(step.welcomeHeadline)
                .font(.subheadline)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .tracking(1.2)
                .apply { view in
                    if #available(iOS 16.1, *) {
                        view.fontDesign(.rounded)
                    }
                }
                .foregroundStyle(viewModel.colorPalette.accentColor)

            Text(step.welcomeSubheadline)
                .font(.title)
                .fontWeight(.bold)
                .apply { view in
                    if #available(iOS 16.1, *) {
                        view.fontDesign(.rounded)
                    }
                }
                .foregroundStyle(viewModel.colorPalette.textColor)
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Rating Section

    private var ratingSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundStyle(Color.yellow.opacity(0.85))
                        .scaleEffect(showStars ? 1 : 0)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.6)
                                .delay(Double(index) * 0.08),
                            value: showStars
                        )
                }
            }

            Text(step.userReview)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .apply { view in
                    if #available(iOS 16.1, *) {
                        view.fontDesign(.rounded)
                    }
                }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 28)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(viewModel.colorPalette.secondaryButtonBackgroundColor.opacity(0.4))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(viewModel.colorPalette.accentColor.opacity(0.2), lineWidth: 1)
                }
        }
    }

    // MARK: - Stats Section

    @ViewBuilder
    private var statsSection: some View {
        if !step.stats.isEmpty {
            HStack(spacing: 0) {
                ForEach(Array(step.stats.enumerated()), id: \.offset) { index, stat in
                    if index > 0 {
                        statDivider
                    }
                    statItem(value: stat.value, label: stat.label)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .apply { view in
                    if #available(iOS 16.1, *) {
                        view.fontDesign(.rounded)
                    }
                }
                .foregroundStyle(viewModel.colorPalette.textColor)

            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
                .textCase(.uppercase)
                .tracking(0.5)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .apply { view in
                    if #available(iOS 16.1, *) {
                        view.fontDesign(.rounded)
                    }
                }
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Circle()
            .fill(viewModel.colorPalette.secondaryTextColor.opacity(0.4))
            .frame(width: 4, height: 4)
    }

    // MARK: - Message Section

    private var messageSection: some View {
        VStack(spacing: 16) {
            Text("\(step.message)")
                .font(.callout)
                .fontWeight(.regular)
                .italic()
                .apply { view in
                    if #available(iOS 16.1, *) {
                        view.fontDesign(.serif)
                    }
                }
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Text(step.messageAuthor)
                .font(.caption)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .tracking(1)
                .apply { view in
                    if #available(iOS 16.1, *) {
                        view.fontDesign(.rounded)
                    }
                }
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Button

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    // MARK: - Animation

    private func animateIn() async {
        try? await Task.sleep(for: .milliseconds(100))
        withAnimation(.easeOut(duration: 0.5)) {
            showContent = true
        }

        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(.easeOut(duration: 0.4)) {
            showStars = true
        }

        try? await Task.sleep(for: .milliseconds(400))
        withAnimation(.easeOut(duration: 0.4)) {
            showStats = true
        }

        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(.easeOut(duration: 0.4)) {
            showMessage = true
        }

        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(.easeOut(duration: 0.4)) {
            showButton = true
        }
    }
}

#Preview {
    MockOnboardingView()
}
