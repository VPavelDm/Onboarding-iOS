//
//  SurvivalFunnelStepView.swift
//  onboarding-ios
//

import SwiftUI
import CoreUI

struct SurvivalFunnelStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var appeared = false
    @State private var isCaptionVisible = false
    @State private var isDescriptionVisible = false
    @State private var isButtonVisible = false

    var step: SurvivalFunnelStep

    private let stageStagger: Double = 0.35
    private let minBarWidthRatio: CGFloat = 0.22
    private let cornerRadius: CGFloat = 14

    private var maxCount: Int {
        step.stages.map(\.count).max() ?? 1
    }

    var body: some View {
        VStack {
            funnelView
                .padding(.horizontal, .hScreenPadding)
                .padding(.top, 48)
            VStack(spacing: .headingSpacing) {
                titleView
                descriptionView
                    .opacity(isDescriptionVisible ? 1 : 0)
                captionView
                    .opacity(isCaptionVisible ? 1 : 0)
            }
            .padding(.horizontal, .hScreenPadding)
            .frame(maxHeight: .infinity, alignment: .top)
            nextButton
                .padding(.horizontal, .hScreenPadding)
                .opacity(isButtonVisible ? 1 : 0)
        }
        .padding(.bottom, .vScreenPadding)
        .ignoresSafeArea(edges: .top)
        .task {
            withAnimation {
                appeared = true
            }
            let totalStageTime = Double(step.stages.count) * stageStagger
            withAnimation(.easeInOut.delay(totalStageTime)) {
                isDescriptionVisible = true
                isCaptionVisible = true
            }
            withAnimation(.easeInOut.delay(totalStageTime + 0.4)) {
                isButtonVisible = true
            }
        }
    }

    // MARK: - Funnel

    private var funnelView: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            VStack(spacing: 8) {
                ForEach(Array(step.stages.enumerated()), id: \.offset) { index, stage in
                    stageBar(stage: stage, isLast: index == step.stages.count - 1, fullWidth: width)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.85)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * stageStagger),
                            value: appeared
                        )

                    if let dropoff = stage.dropoffLabel, index < step.stages.count - 1 {
                        dropoffView(dropoff)
                            .opacity(appeared ? 1 : 0)
                            .animation(
                                .easeInOut(duration: 0.4).delay(Double(index) * stageStagger + 0.2),
                                value: appeared
                            )
                    }
                }
            }
        }
        .aspectRatio(1.1, contentMode: .fit)
    }

    private func stageBar(stage: SurvivalFunnelStep.Stage, isLast: Bool, fullWidth: CGFloat) -> some View {
        let ratio = CGFloat(stage.count) / CGFloat(maxCount)
        let width = max(fullWidth * minBarWidthRatio, fullWidth * ratio)
        return HStack(spacing: 10) {
            Text("\(stage.count)")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(isLast ? viewModel.colorPalette.primaryButtonForegroundColor : viewModel.colorPalette.textColor)
            Text(stage.label)
                .font(.caption.weight(.medium))
                .foregroundStyle(
                    isLast
                        ? viewModel.colorPalette.primaryButtonForegroundColor.opacity(0.7)
                        : viewModel.colorPalette.secondaryTextColor
                )
        }
        .frame(width: width)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isLast ? AnyShapeStyle(viewModel.colorPalette.accentColor) : AnyShapeStyle(Color.white.opacity(0.08)))
        )
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    isLast ? viewModel.colorPalette.accentColor : Color.white.opacity(0.12),
                    lineWidth: 1
                )
        }
        .frame(maxWidth: .infinity)
    }

    private func dropoffView(_ label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.turn.down.right")
                .font(.caption2.weight(.semibold))
            Text(label)
                .font(.caption.italic())
        }
        .foregroundStyle(viewModel.colorPalette.secondaryTextColor.opacity(0.7))
    }

    // MARK: - Copy

    private var titleView: some View {
        Text(viewModel.delegate.format(string: step.title))
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
    }

    @ViewBuilder
    private var captionView: some View {
        if let caption = step.caption {
            Text(caption)
                .multilineTextAlignment(.center)
                .font(.footnote.italic())
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor.opacity(0.8))
        }
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
    }
}

#Preview {
    MockOnboardingView()
}
