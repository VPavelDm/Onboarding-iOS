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
            title
                .padding(.top, 60)
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
        Text(localized("progressBars.title"))
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
        .frame(height: 8)
    }

    private var credibilityBlock: some View {
        HStack(spacing: 16) {
            laurel(.leading)
            creditText
            laurel(.trailing)
        }
    }

    private func laurel(_ direction: LaurelDirection) -> some View {
        Image(systemName: direction == .leading ? "laurel.leading" : "laurel.trailing")
            .font(.system(size: 80))
            .foregroundStyle(viewModel.colorPalette.accentColor)
    }

    private var creditText: some View {
        VStack(spacing: 2) {
            Text(localized("progressBars.creditNumber"))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.colorPalette.textColor)
            Text(localized("progressBars.creditDescription"))
                .font(.callout)
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [makeAnswer()])
        } label: {
            Text(localized("progressBars.answerTitle"))
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
        .opacity(isComplete ? 1 : 0)
        .offset(y: isComplete ? 0 : 20)
        .animation(.easeOut(duration: 0.4), value: isComplete)
    }

    private func localized(_ key: String) -> String {
        viewModel.localizer.localize(key)
    }

    private func makeAnswer() -> StepAnswer {
        StepAnswer(
            title: localized("progressBars.answerTitle"),
            icon: nil,
            nextStepID: step.nextStepID,
            payload: nil
        )
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

#Preview {
    let sampleStep = ProgressBarsStep(
        stepLabels: [
            "Mapping your level and goals",
            "Picking words from your topics",
            "Tuning exercises to your style",
            "Locking in your daily reminder"
        ],
        nextStepID: nil
    )
    let viewModel = OnboardingViewModel(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(onAnswerCallback: {}),
        colorPalette: .testData
    )
    return ProgressBarsStepView(step: sampleStep)
        .environmentObject(viewModel)
        .background(MeshGradientBackground())
        .preferredColorScheme(.dark)
}
