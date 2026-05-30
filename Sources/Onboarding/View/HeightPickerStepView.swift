//
//  HeightPickerStepView.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import SwiftUI
import CoreUI

struct HeightPickerStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var isMetric: Bool = {
        if #available(iOS 16.0, *) {
            return Locale.current.measurementSystem == .metric
        } else {
            return Locale.current.usesMetricSystem
        }
    }()
    @State var centimeters: Int = 170
    @State var feet: Int = 5
    @State var inches: Int = 7

    var step: HeightPickerStep

    var body: some View {
        VStack(spacing: UIConstants.contentSpacing) {
            VStack(spacing: UIConstants.headingSpacing) {
                titleView
                descriptionView
            }
            Spacer()
            unitSelector
            heightPicker
            Spacer()
            continueButton
        }
        .padding(.vertical, UIConstants.vScreenPadding)
        .padding(.horizontal, UIConstants.hScreenPadding)
    }

    private var titleView: some View {
        Text(step.title)
            .multilineTextAlignment(.center)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .padding(.horizontal, UIConstants.titlePadding)
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

    private var unitSelector: some View {
        HStack(spacing: 8) {
            unitButton(title: step.metricUnit, isSelected: isMetric) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isMetric = true
                }
            }
            unitButton(title: step.imperialUnit, isSelected: !isMetric) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isMetric = false
                }
            }
        }
    }

    private func unitButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? viewModel.colorPalette.primaryButtonForegroundColor : viewModel.colorPalette.textColor)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(isSelected ? viewModel.colorPalette.primaryButtonBackground : AnyShapeStyle(.clear))
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
            ForEach(Array(100...250), id: \.self) { cm in
                Text("\(cm) \(step.metricUnit)")
                    .foregroundStyle(viewModel.colorPalette.textColor)
                    .tag(cm)
            }
        }
        .wheelPickerStyleCompat()
        .onChange(of: centimeters) { newValue in
            updateImperialFromMetric(cm: newValue)
        }
    }

    private var imperialPicker: some View {
        HStack(spacing: 0) {
            Picker("Feet", selection: $feet) {
                ForEach(Array(3...8), id: \.self) { ft in
                    Text("\(ft)'")
                        .foregroundStyle(viewModel.colorPalette.textColor)
                        .tag(ft)
                }
            }
            .wheelPickerStyleCompat()

            Picker("Inches", selection: $inches) {
                ForEach(Array(0...11), id: \.self) { inch in
                    Text("\(inch)\"")
                        .foregroundStyle(viewModel.colorPalette.textColor)
                        .tag(inch)
                }
            }
            .wheelPickerStyleCompat()
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
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
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

#if !os(Android)
#Preview {
    MockOnboardingView()
}
#endif
