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
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let subtitle = step.subtitle {
            Text(subtitle)
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
            accentOperand(step.operandLeft)
            symbolView
            accentOperand(step.operandRight)
        }
    }

    private var symbolView: some View {
        Text(step.operandSymbol)
            .font(.system(size: 26, weight: .light, design: .rounded))
            .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.4))
            .padding(.bottom, 18)
    }

    private func accentOperand(_ operand: FormulaStep.Operand) -> some View {
        operandView(operand, accent: true)
    }

    private var resultOperand: some View {
        operandView(step.result, accent: false)
    }

    private func operandView(_ operand: FormulaStep.Operand, accent: Bool) -> some View {
        VStack(spacing: 4) {
            Text(operand.number)
                .font(.system(size: accent ? 42 : 60, weight: .bold, design: .rounded))
                .foregroundStyle(accent ? viewModel.colorPalette.accentColor : viewModel.colorPalette.textColor)
                .monospacedDigit()
            Text(operand.label)
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
            Text(row.value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(viewModel.colorPalette.textColor)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassBackground(cornerRadius: 14)
    }

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
        .opacity(showCTA ? 1 : 0)
        .offset(y: showCTA ? 0 : 16)
        .animation(.easeOut(duration: 0.4), value: showCTA)
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
