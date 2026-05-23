import SwiftUI
import CoreUI

struct MilestoneTimelineStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var triggered = false

    let step: MilestoneTimelineStep

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            header
            timelineCard
            Spacer()
            continueButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .onAppear { triggered = true }
    }

    private var header: some View {
        VStack(spacing: 12) {
            titleView
            subtitleView
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let subtitle = step.subtitle {
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }

    private var timelineCard: some View {
        MilestoneTimeline(
            milestones: step.milestones,
            floatingLabel: step.floatingLabel,
            triggered: triggered
        )
        .frame(height: 92)
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .glassBackground(cornerRadius: 16)
    }

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
    }
}

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

private struct MilestoneTimeline: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    let milestones: [MilestoneTimelineStep.Milestone]
    let floatingLabel: String?
    let triggered: Bool

    var body: some View {
        GeometryReader { proxy in
            let lineY = proxy.size.height * 0.55
            ZStack(alignment: .topLeading) {
                axisLine(width: proxy.size.width, y: lineY)
                segments(width: proxy.size.width, y: lineY)
                ForEach(milestones, id: \.label) { milestone in
                    marker(milestone: milestone, width: proxy.size.width, lineY: lineY)
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

    private func marker(milestone: MilestoneTimelineStep.Milestone, width: CGFloat, lineY: CGFloat) -> some View {
        let cx = milestone.xRatio * width
        return ZStack {
            floatingChip
                .position(x: cx, y: lineY - 26)
            dot
                .position(x: cx, y: lineY)
            Text(milestone.label)
                .font(.caption2)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .position(x: cx, y: lineY + 22)
        }
        .opacity(triggered ? 1 : 0)
        .animation(.easeOut(duration: 0.35).delay(milestone.delay), value: triggered)
    }

    @ViewBuilder
    private var floatingChip: some View {
        if let label = floatingLabel {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(viewModel.colorPalette.textColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    viewModel.colorPalette.accentColor.opacity(0.22),
                    in: Capsule()
                )
                .overlay(
                    Capsule().strokeBorder(
                        viewModel.colorPalette.accentColor.opacity(0.6),
                        lineWidth: 0.5
                    )
                )
        }
    }

    private var dot: some View {
        Circle()
            .fill(viewModel.colorPalette.accentColor)
            .frame(width: 9, height: 9)
    }
}
