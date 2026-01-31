//
//  HeightPickerStepView.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import SwiftUI

struct HeightPickerStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var isMetric: Bool = {
        if #available(iOS 16.0, *) {
            return Locale.current.measurementSystem == .metric
        } else {
            return Locale.current.usesMetricSystem
        }
    }()
    @State private var centimeters: Int = 170
    @State private var feet: Int = 5
    @State private var inches: Int = 7

    var step: HeightPickerStep

    var body: some View {
        VStack(spacing: .contentSpacing) {
            VStack(spacing: .headingSpacing) {
                titleView
                descriptionView
            }
            Spacer()
            unitToggleButton
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
                .font(.body)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
    }

    private var unitToggleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isMetric.toggle()
            }
        } label: {
            Text(isMetric ? "cm" : "ft")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(viewModel.colorPalette.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
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
