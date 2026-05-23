import SwiftUI
import CoreUI

struct FormulaStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var showEquation = false
    @State private var visibleDetailRows = 0
    @State private var showCTA = false

    let step: FormulaStep

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            header
            VStack(spacing: 14) {
                equationCard
                detailRowsSection
            }
            Spacer()
            continueButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .task {
            await animateIn()
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            titleView
            subtitleView
        }
        .multilineTextAlignment(.center)
    }

    private var titleView: some View {
        Text(localized("formula.title"))
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
    }

    @ViewBuilder
    private var subtitleView: some View {
        let text = localized("formula.subtitle")
        if !text.isEmpty {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
    }

    private var equationCard: some View {
        VStack(spacing: 22) {
            operandsRow
            divider
            resultOperand
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .glassBackground(cornerRadius: 24)
        .opacity(showEquation ? 1 : 0)
        .scaleEffect(showEquation ? 1 : 0.94)
    }

    private var operandsRow: some View {
        HStack(spacing: 24) {
            accentOperand(number: viewModel.format(string: step.operandLeftNumber), label: localized("formula.operandLeftLabel"))
            symbolView
            accentOperand(number: viewModel.format(string: step.operandRightNumber), label: localized("formula.operandRightLabel"))
        }
    }

    private var symbolView: some View {
        Text(localized("formula.operandSymbol"))
            .font(.system(size: 26, weight: .light, design: .rounded))
            .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.4))
            .padding(.bottom, 18)
    }

    private func accentOperand(number: String, label: String) -> some View {
        operandView(number: number, label: label, accent: true)
    }

    private var resultOperand: some View {
        operandView(number: viewModel.format(string: step.resultNumber), label: localized("formula.resultLabel"), accent: false)
    }

    private func operandView(number: String, label: String, accent: Bool) -> some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.system(size: accent ? 42 : 60, weight: .bold, design: .rounded))
                .foregroundStyle(accent ? viewModel.colorPalette.accentColor : viewModel.colorPalette.textColor)
                .monospacedDigit()
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.7))
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(viewModel.colorPalette.textColor.opacity(0.15))
            .frame(height: 1)
            .padding(.horizontal, 40)
    }

    private var detailRowsSection: some View {
        VStack(spacing: 8) {
            ForEach(step.detailRows.indices, id: \.self) { index in
                detailRowView(step.detailRows[index])
                    .opacity(index < visibleDetailRows ? 1 : 0)
                    .offset(x: index < visibleDetailRows ? 0 : -16)
            }
        }
    }

    private func detailRowView(_ row: FormulaStep.DetailRow) -> some View {
        HStack(spacing: 12) {
            Text(row.label)
                .font(.caption.weight(.medium))
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.5))
                .frame(width: 70, alignment: .leading)
                .lineLimit(1)
            Text(viewModel.format(string: row.value))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(viewModel.colorPalette.textColor)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassBackground(cornerRadius: 14)
    }

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [makeAnswer()])
        } label: {
            Text(localized("formula.answerTitle"))
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
        .opacity(showCTA ? 1 : 0)
        .offset(y: showCTA ? 0 : 16)
        .animation(.easeOut(duration: 0.4), value: showCTA)
    }

    private func localized(_ key: String) -> String {
        viewModel.localizer.localize(key)
    }

    private func makeAnswer() -> StepAnswer {
        StepAnswer(
            title: localized("formula.answerTitle"),
            icon: nil,
            nextStepID: step.nextStepID,
            payload: nil
        )
    }

    private func animateIn() async {
        try? await Task.sleep(for: .milliseconds(250))
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            showEquation = true
        }
        try? await Task.sleep(for: .milliseconds(450))
        for index in step.detailRows.indices {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                visibleDetailRows = index + 1
            }
            try? await Task.sleep(for: .milliseconds(150))
        }
        try? await Task.sleep(for: .milliseconds(200))
        showCTA = true
    }
}

#Preview {
    let sampleStep = FormulaStep(
        operandLeftNumber: "10",
        operandRightNumber: "365",
        resultNumber: "3,650",
        detailRows: [
            .init(label: "Built on", value: "Travel · Food · Tech · Career"),
            .init(label: "Enabled",  value: "Daily · Listen · Focus"),
            .init(label: "Target",   value: "B1 in 90 days")
        ],
        nextStepID: nil
    )
    let viewModel = OnboardingViewModel(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(onAnswerCallback: {}),
        colorPalette: .testData
    )
    return FormulaStepView(step: sampleStep)
        .environmentObject(viewModel)
        .background(MeshGradientBackground())
        .preferredColorScheme(.dark)
}
