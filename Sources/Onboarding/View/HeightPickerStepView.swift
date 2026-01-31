//
//  HeightPickerStepView.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import SwiftUI

struct HeightPickerStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var isMetric: Bool = Locale.current.usesMetricSystem
    @State private var centimeters: Int = 170
    @State private var feet: Int = 5
    @State private var inches: Int = 7

    var step: HeightPickerStep

    private var heightString: String {
        if isMetric {
            return "\(centimeters) cm"
        } else {
            return "\(feet)'\(inches)\""
        }
    }

    var body: some View {
        VStack(spacing: .contentSpacing) {
            VStack(spacing: .headingSpacing) {
                titleView
                descriptionView
            }
            Spacer()
            unitSelector
            heightPicker
            Spacer()
            continueButton
        }
        .padding(.vertical, .vScreenPadding)
        .padding(.horizontal, .hScreenPadding)
    }

    private var titleView: some View {
        Text(step.title)
            .multilineTextAlignment(.center)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .padding(.horizontal, .titlePadding)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .multilineTextAlignment(.center)
                .font(.title3)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
    }

    private var unitSelector: some View {
        HStack(spacing: 0) {
            unitButton(title: step.metricTitle, isSelected: isMetric) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isMetric = true
                }
            }
            unitButton(title: step.imperialTitle, isSelected: !isMetric) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isMetric = false
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func unitButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? viewModel.colorPalette.primaryButtonForegroundColor : viewModel.colorPalette.secondaryTextColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? viewModel.colorPalette.primaryButtonBackgroundColor : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(4)
    }

    private var heightPicker: some View {
        Group {
            if isMetric {
                metricPicker
            } else {
                imperialPicker
            }
        }
        .frame(height: 200)
    }

    private var metricPicker: some View {
        Picker("Height", selection: $centimeters) {
            ForEach(100...250, id: \.self) { cm in
                Text("\(cm) cm")
                    .foregroundStyle(viewModel.colorPalette.textColor)
                    .tag(cm)
            }
        }
        .pickerStyle(.wheel)
        .onChange(of: centimeters) { newValue in
            updateImperialFromMetric(cm: newValue)
        }
    }

    private var imperialPicker: some View {
        HStack(spacing: 0) {
            Picker("Feet", selection: $feet) {
                ForEach(3...8, id: \.self) { ft in
                    Text("\(ft)'")
                        .foregroundStyle(viewModel.colorPalette.textColor)
                        .tag(ft)
                }
            }
            .pickerStyle(.wheel)

            Picker("Inches", selection: $inches) {
                ForEach(0...11, id: \.self) { inch in
                    Text("\(inch)\"")
                        .foregroundStyle(viewModel.colorPalette.textColor)
                        .tag(inch)
                }
            }
            .pickerStyle(.wheel)
        }
        .onChange(of: feet) { _ in
            updateMetricFromImperial()
        }
        .onChange(of: inches) { _ in
            updateMetricFromImperial()
        }
    }

    private var continueButton: some View {
        AsyncButton {
            await onContinue()
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private func onContinue() async {
        var answer = step.answer
        answer.payload = .string("\(centimeters)")
        await viewModel.onAnswer(answers: [answer])
    }

    private func updateImperialFromMetric(cm: Int) {
        let totalInches = Double(cm) / 2.54
        feet = Int(totalInches) / 12
        inches = Int(totalInches.rounded()) % 12
    }

    private func updateMetricFromImperial() {
        let totalInches = Double(feet * 12 + inches)
        centimeters = Int((totalInches * 2.54).rounded())
    }
}

// MARK: - Preview

#Preview {
    MockOnboardingView()
}
