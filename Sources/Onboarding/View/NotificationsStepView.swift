import SwiftUI
import CoreUI

/// Shows the notifications the app will actually send, stacked the way the system stacks them, and
/// asks for permission underneath. The stack fans out on a tap, so the promise can be read in full
/// before it is accepted.
struct NotificationsStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let step: NotificationsStep

    @State private var revealedBanners = 0
    @State private var showsHeader = false
    @State private var showsButton = false
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .opacity(showsHeader ? 1 : 0)
                .padding(.horizontal)
            Spacer(minLength: .stackTopGap)
            bannerStack
                .padding(.horizontal)
            Spacer()
            Spacer()
            buttons
                .opacity(showsButton ? 1 : 0)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .task { await reveal() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(localized(step.title))
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(viewModel.colorPalette.textColor)
                .multilineTextAlignment(.center)
            if let description = step.description {
                Text(localized(description))
                    .font(.subheadline)
                    .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Banners

    /// The banners are drawn back to front: the newest sits flat on top and the ones under it are
    /// scaled and pushed down, which is the shape a notification stack has on the lock screen.
    private var bannerStack: some View {
        ZStack {
            ForEach(Array(step.banners.enumerated()), id: \.offset) { index, banner in
                bannerView(banner, showsContent: isExpanded || index == revealedBanners - 1)
                    .scaleEffect(isExpanded ? 1 : 1 - .scalePerLayer * CGFloat(depth(of: index)))
                    .offset(y: offset(of: index))
                    .opacity(opacity(of: index))
                    .zIndex(Double(index))
            }
        }
        .frame(height: stackHeight, alignment: .top)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(duration: 0.4, bounce: 0.1)) { isExpanded.toggle() }
        }
    }

    /// Only the banner on top of the stack shows its message, as the ones under it do on a lock
    /// screen. That also keeps the stack's edges clean: a banner with more to say is taller, and
    /// while it is stacked its text would otherwise appear in the gap under the one above it.
    private func bannerView(_ banner: NotificationsStep.Banner, showsContent: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            bellIcon
            VStack(alignment: .leading, spacing: 2) {
                // Three tiers, as a real banner has them: who sent it and when, then what it
                // says, then the detail. The sender sits with the timestamp rather than with the
                // message, which is what stops it reading as a second title.
                HStack {
                    Text(verbatim: step.appName)
                        .font(.system(size: 12))
                        .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                    Spacer(minLength: 8)
                    Text(localized(.nowKey))
                        .font(.system(size: 12))
                        .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                }
                Text(localized(banner.title))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(viewModel.colorPalette.textColor)
                Text(localized(banner.body))
                    .font(.system(size: 14))
                    .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.75))
                    .lineLimit(2)
            }
        }
        .opacity(showsContent ? 1 : 0)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay {
                    // A hint of the accent, not a wash of it: the palette's colour sits over a dark
                    // background here, and at any strength it stops reading as a system banner.
                    RoundedRectangle(cornerRadius: 16)
                        .fill(viewModel.colorPalette.accentColor.opacity(0.07))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(viewModel.colorPalette.accentColor.opacity(0.3), lineWidth: 1)
                }
        }
    }

    private var bellIcon: some View {
        Image(systemName: "bell.badge.fill")
            .font(.system(size: 17))
            .foregroundStyle(viewModel.colorPalette.accentColor)
            .frame(width: 38, height: 38)
            .background(viewModel.colorPalette.accentColor.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Stack geometry

    /// How far below the top of the stack a banner sits. The newest is on top, so the first banner
    /// sinks as the later ones arrive.
    private func depth(of index: Int) -> Int {
        max(revealedBanners - 1 - index, 0)
    }

    private func offset(of index: Int) -> CGFloat {
        guard index < revealedBanners else { return -.arrivalOffset }
        let spacing: CGFloat = isExpanded ? .expandedSpacing : .collapsedSpacing
        return spacing * CGFloat(depth(of: index))
    }

    private func opacity(of index: Int) -> Double {
        guard index < revealedBanners else { return 0 }
        guard !isExpanded else { return 1 }
        return max(1 - .fadePerLayer * Double(depth(of: index)), 0)
    }

    private var stackHeight: CGFloat {
        let layers = CGFloat(max(step.banners.count - 1, 0))
        return .bannerHeight + (isExpanded ? .expandedSpacing * layers : .collapsedSpacing * layers)
    }

    // MARK: - Buttons

    private var buttons: some View {
        VStack(spacing: 12) {
            AsyncButton {
                await viewModel.onAnswer(answers: [allowAnswer])
            } label: {
                Text(localized(step.buttonTitle))
            }
            .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))

            if let skip = step.skip {
                AsyncButton {
                    await viewModel.onAnswer(answers: [routed(skip)])
                } label: {
                    Text(localized(skip.title))
                }
                .buttonStyle(SecondaryButtonStyle(colorPalette: viewModel.colorPalette))
            }
        }
    }

    private var allowAnswer: StepAnswer {
        routed(StepAnswer(title: step.buttonTitle, icon: nil, nextStepID: nil, payload: nil))
    }

    private func routed(_ answer: StepAnswer) -> StepAnswer {
        var routed = answer
        routed.nextStepID = answer.nextStepID ?? step.nextStepID
        return routed
    }

    private func localized(_ key: String) -> String {
        viewModel.localize(key)
    }

    private func reveal() async {
        withAnimation(.easeOut(duration: 0.4)) { showsHeader = true }
        try? await Task.sleep(for: .milliseconds(500))
        for index in step.banners.indices {
            withAnimation(.spring(duration: 0.5, bounce: 0.15)) { revealedBanners = index + 1 }
            try? await Task.sleep(for: .milliseconds(700))
        }
        withAnimation(.easeInOut(duration: 0.4)) { showsButton = true }
    }
}

private extension CGFloat {

    /// What the stack reserves for the banner on top, so the layout does not move when the rest
    /// fan out from under it.
    static let bannerHeight: CGFloat = 92

    /// Leaves the stack near the top of the screen, where a notification would arrive.
    static let stackTopGap: CGFloat = 40

    /// How far a banner sits below the one on top of it, stacked and fanned out.
    static let collapsedSpacing: CGFloat = 10
    static let expandedSpacing: CGFloat = 86

    /// Where a banner starts before it drops into the stack.
    static let arrivalOffset: CGFloat = 30

    static let scalePerLayer: CGFloat = 0.06
}

private extension Double {

    static let fadePerLayer: Double = 0.25
}

private extension String {

    /// The timestamp the system would put on a notification that just arrived.
    static let nowKey = "Now"
}
