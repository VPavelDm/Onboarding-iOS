import SwiftUI
import CoreUI

struct MilestoneTimelineStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var triggered = false
    @State var showCTA = false

    let step: MilestoneTimelineStep

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            header
            timelineCard
            Spacer()
            continueButton
        }
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.bottom, UIConstants.vScreenPadding)
        .task {
#if !os(Android)
            try? await Task.sleep(for: .seconds(0.35))
#endif
            triggered = true
            let lastDelay = step.milestones.map(\.delay).max() ?? 0
            try? await Task.sleep(for: .seconds(lastDelay + 0.4))
            showCTA = true
        }
    }

    private var header: some View {
        VStack(spacing: UIConstants.headingSpacing) {
            titleView
            subtitleView
        }
    }

    private var titleView: some View {
        Text(localized("milestoneTimeline.title"))
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var subtitleView: some View {
        let text = localized("milestoneTimeline.subtitle")
        if !text.isEmpty {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }

    private var timelineCard: some View {
        MilestoneTimeline(
            milestones: step.milestones,
            floatingLabel: localized("milestoneTimeline.floatingLabel"),
            triggered: triggered
        )
        .frame(height: 92)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .glassBackground(cornerRadius: 16)
    }

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [makeAnswer()])
        } label: {
            Text(localized("milestoneTimeline.answerTitle"))
                .applyRippleEffect()
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
        .revealBottomButton(showCTA)
    }

    private func localized(_ key: String) -> String {
        viewModel.localize(key)
    }

    private func makeAnswer() -> StepAnswer {
        StepAnswer(
            title: localized("milestoneTimeline.answerTitle"),
            icon: nil,
            nextStepID: step.nextStepID,
            payload: nil
        )
    }
}

#if os(Android)
struct MilestoneTimeline: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let milestones: [MilestoneTimelineStep.Milestone]
    let floatingLabel: String
    let triggered: Bool

    @State var revealed = 1

    var body: some View {
        GeometryReader { proxy in
            let lineY = proxy.size.height * 0.55
            ZStack(alignment: .topLeading) {
                axisLine(width: proxy.size.width, y: lineY)
                segments(width: proxy.size.width, y: lineY)
                ForEach(Array(milestones.enumerated()), id: \.element.label) { index, milestone in
                    marker(milestone: milestone, index: index, width: proxy.size.width, lineY: lineY)
                }
            }
        }
        .task { await revealSequence() }
    }

    private func revealSequence() async {
        try? await Task.sleep(for: .seconds(0.35))
        for index in milestones.indices {
            let prior = index == 0 ? 0 : milestones[index - 1].delay
            try? await Task.sleep(for: .seconds(max(0, milestones[index].delay - prior)))

            let slot = index < milestones.count - 1
                ? milestones[index + 1].delay - milestones[index].delay
                : 0.5
            withAnimation(.easeOut(duration: min(0.5, max(0.3, slot)))) {
                revealed = index + 1
            }
        }
    }

    private func axisLine(width: CGFloat, y: CGFloat) -> some View {
        Path { p in
            p.move(to: CGPoint(x: 0, y: y))
            p.addLine(to: CGPoint(x: width, y: y))
        }
        .stroke(viewModel.colorPalette.textColor.opacity(0.18), lineWidth: 1)
    }

    private func segments(width: CGFloat, y: CGFloat) -> some View {
        ForEach(0..<max(milestones.count - 1, 0), id: \.self) { i in
            segmentView(index: i, width: width, y: y)
        }
    }

    private func segmentView(index: Int, width: CGFloat, y: CGFloat) -> some View {
        let from = milestones[index]
        let to = milestones[index + 1]

        let segWidth = (to.xRatio - from.xRatio) * width
        let segCenterX = (from.xRatio + to.xRatio) / 2 * width

        return Rectangle()
            .fill(viewModel.colorPalette.accentColor.opacity(0.75))
            .frame(width: segWidth, height: 1.5)
            .scaleEffect(x: revealed > index + 1 ? 1 : 0, anchor: .leading)
            .position(x: segCenterX, y: y)
    }

    private func marker(milestone: MilestoneTimelineStep.Milestone, index: Int, width: CGFloat, lineY: CGFloat) -> some View {
        let cx = milestone.xRatio * width
        return ZStack {
            floatingChip
                .position(x: cx, y: lineY - 26)
            dot
                .position(x: cx, y: lineY)
            Text(viewModel.localize(milestone.label))
                .font(.caption2)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .position(x: cx, y: lineY + 22)
        }
        .opacity(revealed > index ? 1 : 0)
        .scaleEffect(revealed > index ? 1 : 0.6)
    }

    @ViewBuilder
    private var floatingChip: some View {
        if !floatingLabel.isEmpty {
            Text(floatingLabel)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(viewModel.colorPalette.textColor)
                .accentChip(color: viewModel.colorPalette.accentColor)
        }
    }

    private var dot: some View {
        Circle()
            .fill(viewModel.colorPalette.accentColor)
            .frame(width: 9, height: 9)
    }
}
#else
private struct MilestoneSegmentShape: Shape {
    var trimTo: CGFloat

    var animatableData: CGFloat {
        get { trimTo }
        set { trimTo = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.minX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.minX + rect.width * trimTo, y: rect.midY))
        }
    }
}

struct MilestoneTimeline: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    let milestones: [MilestoneTimelineStep.Milestone]
    let floatingLabel: String
    let triggered: Bool

    var body: some View {
        GeometryReader { proxy in
            let lineY = proxy.size.height * 0.55
            ZStack(alignment: .topLeading) {
                axisLine(width: proxy.size.width, y: lineY)
                segments(width: proxy.size.width, y: lineY)
                ForEach(Array(milestones.enumerated()), id: \.element.label) { index, milestone in
                    marker(milestone: milestone, index: index, width: proxy.size.width, lineY: lineY)
                }
            }
        }
    }

    private func axisLine(width: CGFloat, y: CGFloat) -> some View {
        Path { p in
            p.move(to: CGPoint(x: 0, y: y))
            p.addLine(to: CGPoint(x: width, y: y))
        }
        .stroke(viewModel.colorPalette.textColor.opacity(0.18), lineWidth: 1)
    }

    private func segments(width: CGFloat, y: CGFloat) -> some View {
        ForEach(0..<max(milestones.count - 1, 0), id: \.self) { i in
            segmentView(index: i, width: width, y: y)
        }
    }

    private func segmentView(index: Int, width: CGFloat, y: CGFloat) -> some View {
        let from = milestones[index]
        let to = milestones[index + 1]

        let segWidth = (to.xRatio - from.xRatio) * width
        let segCenterX = (from.xRatio + to.xRatio) / 2 * width

        let drawStart = from.delay + 0.05
        let drawDuration = max(0.15, to.delay - drawStart - 0.02)

        return MilestoneSegmentShape(trimTo: triggered ? 1 : 0)
            .stroke(
                viewModel.colorPalette.accentColor.opacity(0.75),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
            )
            .frame(width: segWidth, height: 4)
            .position(x: segCenterX, y: y)
            .animation(.easeInOut(duration: drawDuration).delay(drawStart), value: triggered)
    }

    private func marker(milestone: MilestoneTimelineStep.Milestone, index: Int, width: CGFloat, lineY: CGFloat) -> some View {
        let cx = milestone.xRatio * width
        return ZStack {
            floatingChip
                .position(x: cx, y: lineY - 26)
            dot
                .position(x: cx, y: lineY)
            Text(viewModel.localize(milestone.label))
                .font(.caption2)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .position(x: cx, y: lineY + 22)
        }
        .opacity(triggered ? 1 : 0)
        .animation(.easeOut(duration: 0.35).delay(milestone.delay), value: triggered)
    }

    @ViewBuilder
    private var floatingChip: some View {
        if !floatingLabel.isEmpty {
            Text(floatingLabel)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(viewModel.colorPalette.textColor)
                .accentChip(color: viewModel.colorPalette.accentColor)
        }
    }

    private var dot: some View {
        Circle()
            .fill(viewModel.colorPalette.accentColor)
            .frame(width: 9, height: 9)
    }
}
#endif
