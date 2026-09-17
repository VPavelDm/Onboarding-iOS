import SwiftUI
import CoreUI

struct ReceiptStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var visibleItems = 0
    @State var showTotal = false
    @State var showStamp = false
    @State var showCTA = false

    let step: ReceiptStep

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            receipt
            Spacer()
            ctaSection
        }
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.bottom, UIConstants.vScreenPadding)
        .task {
            await animateIn()
        }
    }

    private var receipt: some View {
        VStack(spacing: 0) {
            header
                .padding(.bottom, 16)
            itemRows
            dottedLine
                .padding(.vertical, 14)
            totalRow
                .opacity(showTotal ? 1 : 0)
            stamp
                .padding(.top, 24)
                .opacity(showStamp ? 1 : 0)
                .scaleEffect(showStamp ? 1 : 0.7)
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 28)
        .frame(maxWidth: 360)
        .glassBackground(cornerRadius: 20)
    }

    private var header: some View {
        VStack(spacing: 10) {
            headerTitle
            headerSubtitle
            dottedLine
        }
    }

    private var headerTitle: some View {
        Text(localized("receipt.headerTitle"))
            .font(.system(.headline, design: .monospaced).weight(.heavy))
            .tracking(3)
            .foregroundStyle(viewModel.colorPalette.textColor)
    }

    @ViewBuilder
    private var headerSubtitle: some View {
        let text = localized("receipt.headerSubtitle")
        if !text.isEmpty {
            Text(text)
                .font(.system(.caption, design: .monospaced).weight(.medium))
                .tracking(2)
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.55))
        }
    }

    private var dottedLine: some View {
        Text(String(repeating: "·", count: 60))
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.35))
            .lineLimit(1)
    }

    /// Rows sit on rules of their own, so four lines of the same monospaced
    /// face read as four items rather than one block (Lyncil, 2026-09-17:
    /// "it's difficult to differentiate rows"). The rule is a dashed hairline
    /// set in from the leading edge, not the dotted line that frames the
    /// block, so an inner rule never reads as an edge.
    private var itemRows: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(step.items.indices, id: \.self) { index in
                itemRow(step.items[index])
                    .padding(.vertical, 8)
                    .opacity(index < visibleItems ? 1 : 0)
                if index < step.items.count - 1 {
                    itemRule
                        .opacity(index < visibleItems ? 1 : 0)
                }
            }
        }
        .font(.system(.callout, design: .monospaced))
        .foregroundStyle(viewModel.colorPalette.textColor)
    }

    private var itemRule: some View {
        DashedRule()
            .stroke(viewModel.colorPalette.textColor.opacity(0.22), style: StrokeStyle(lineWidth: 1, dash: [7, 5]))
            .frame(height: 1)
            .padding(.leading, 14)
    }

    private struct DashedRule: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            return path
        }
    }

    private func itemRow(_ label: String) -> some View {
        HStack {
            Text(viewModel.localize(label))
            Spacer()
            Text(localized("receipt.itemValue"))
                .fontWeight(.bold)
                .foregroundStyle(viewModel.colorPalette.accentColor)
        }
    }

    private var totalRow: some View {
        HStack {
            Text(localized("receipt.total"))
                .font(.system(.headline, design: .monospaced).weight(.heavy))
            Spacer()
            Text(localized("receipt.totalValue"))
                .font(.system(.title3, design: .monospaced).weight(.heavy))
                .foregroundStyle(viewModel.colorPalette.accentColor)
        }
        .foregroundStyle(viewModel.colorPalette.textColor)
    }

    private var stamp: some View {
        Text(localized("receipt.stamp"))
            .font(.system(.headline, design: .monospaced).weight(.heavy))
            .tracking(2)
            .foregroundStyle(viewModel.colorPalette.accentColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(viewModel.colorPalette.accentColor, lineWidth: 2)
            }
            .rotationEffect(.degrees(-4))
    }

    private var ctaSection: some View {
        VStack(spacing: UIConstants.buttonsSpacing) {
            continueButton
            disclaimer
        }
        .revealBottomButton(showCTA)
    }

    private var continueButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: [makeAnswer()])
        } label: {
            Text(localized("receipt.answerTitle"))
                .applyRippleEffect()
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
    }

    @ViewBuilder
    private var disclaimer: some View {
        let text = localized("receipt.disclaimer")
        if !text.isEmpty {
            Text(text)
                .font(.caption)
                .foregroundStyle(viewModel.colorPalette.textColor.opacity(0.5))
        }
    }

    private func localized(_ key: String) -> String {
        let template = viewModel.localize(key)
        guard template.contains("%d") else { return template }
        let days = viewModel.delegate.subscriptionInfo()?.trialDays ?? 3
        return String(format: template, days)
    }

    private func makeAnswer() -> StepAnswer {
        StepAnswer(
            title: localized("receipt.answerTitle"),
            icon: nil,
            nextStepID: step.nextStepID,
            payload: nil
        )
    }

    private func animateIn() async {
        try? await Task.sleep(for: .milliseconds(250))
        for index in step.items.indices {
            withAnimation(.easeOut(duration: 0.25)) {
                visibleItems = index + 1
            }
            try? await Task.sleep(for: .milliseconds(160))
        }
        try? await Task.sleep(for: .milliseconds(220))
        withAnimation(.easeOut(duration: 0.3)) {
            showTotal = true
        }
        try? await Task.sleep(for: .milliseconds(350))
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            showStamp = true
        }
        try? await Task.sleep(for: .milliseconds(250))
        showCTA = true
    }
}
