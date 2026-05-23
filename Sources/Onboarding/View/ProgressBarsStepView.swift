import SwiftUI
import CoreUI

struct ProgressBarsStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var stepProgress: [Double] = []
    @State private var isComplete = false

    let step: ProgressBarsStep

    private let stepDuration: Double = 1.4
    private let stepGap: Double = 0.2

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 60)
            title
                .padding(.bottom, 48)
            stepsList
            Spacer()
            credibilityBlock
                .frame(maxWidth: .infinity)
                .padding(.bottom, 32)
            continueButton
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .task {
            stepProgress = Array(repeating: 0, count: step.stepLabels.count)
            await runProgress()
        }
    }

    private var title: some View {
        Text(step.title)
            .font(.system(size: 32, weight: .bold))
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stepsList: some View {
        VStack(alignment: .leading, spacing: 28) {
            ForEach(step.stepLabels.indices, id: \.self) { index in
                stepRow(index: index)
            }
        }
    }

    private func stepRow(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(step.stepLabels[index])
                .font(.title3.weight(.semibold))
                .foregroundStyle(
                    progress(at: index) > 0
                        ? viewModel.colorPalette.textColor
                        : viewModel.colorPalette.textColor.opacity(0.35)
                )
            progressBar(progress: progress(at: index))
        }
    }

    private func progress(at index: Int) -> Double {
        index < stepProgress.count ? stepProgress[index] : 0
    }

    private func progressBar(progress: Double) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.clear)
                    .glassBackground(cornerRadius: 6)
                Capsule()
                    .fill(viewModel.colorPalette.accentColor)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 12)
    }

    @ViewBuilder
    private var credibilityBlock: some View {
        if step.creditNumber != nil || !step.creditDescription.isEmpty {
            HStack(spacing: 16) {
                laurel(.leading)
                creditText
                laurel(.trailing)
            }
        }
    }

    private func laurel(_ direction: LaurelDirection) -> some View {
        Image(systemName: direction == .leading ? "laurel.leading" : "laurel.trailing")
            .font(.system(size: 80))
            .foregroundStyle(viewModel.colorPalette.accentColor)
    }

    private var creditText: some View {
        VStack(spacing: 2) {
            if let number = step.creditNumber {
                Text(number)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.colorPalette.textColor)
            }
            ForEach(step.creditDescription.indices, id: \.self) { index in
                Text(step.creditDescription[index])
                    .font(.callout)
                    .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.7))
            }
        }
    }

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
        .opacity(isComplete ? 1 : 0)
        .offset(y: isComplete ? 0 : 20)
        .animation(.easeOut(duration: 0.4), value: isComplete)
    }

    private func runProgress() async {
        try? await Task.sleep(for: .milliseconds(400))
        for index in stepProgress.indices {
            withAnimation(.linear(duration: stepDuration)) {
                stepProgress[index] = 1
            }
            try? await Task.sleep(for: .seconds(stepDuration + stepGap))
        }
        isComplete = true
    }

    private enum LaurelDirection {
        case leading, trailing
    }
}
