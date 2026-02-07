//
//  WeightPickerStepView.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import SwiftUI
import CoreUI

struct WeightPickerStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var isMetric: Bool = {
        if #available(iOS 16.0, *) {
            return Locale.current.measurementSystem == .metric
        } else {
            return Locale.current.usesMetricSystem
        }
    }()
    @State private var kilograms: Int = 70
    @State private var pounds: Int = 154

    var step: WeightPickerStep

    var body: some View {
        VStack(spacing: .contentSpacing) {
            VStack(spacing: .headingSpacing) {
                titleView
                descriptionView
            }
            Spacer()
            unitSelector
            weightPicker
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

    private var weightPicker: some View {
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
        Picker("Weight", selection: $kilograms) {
            ForEach(30...250, id: \.self) { kg in
                Text("\(kg) \(step.metricUnit)")
                    .foregroundStyle(viewModel.colorPalette.textColor)
                    .tag(kg)
            }
        }
        .pickerStyle(.wheel)
        .onChange(of: kilograms) { newValue in
            updateImperialFromMetric(kg: newValue)
        }
    }

    private var imperialPicker: some View {
        Picker("Weight", selection: $pounds) {
            ForEach(66...550, id: \.self) { lb in
                Text("\(lb) \(step.imperialUnit)")
                    .foregroundStyle(viewModel.colorPalette.textColor)
                    .tag(lb)
            }
        }
        .pickerStyle(.wheel)
        .onChange(of: pounds) { _ in
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
        answer.payload = .string("\(kilograms)")
        await viewModel.onAnswer(answers: [answer])
    }

    private func updateImperialFromMetric(kg: Int) {
        pounds = Int((Double(kg) * 2.20462).rounded())
    }

    private func updateMetricFromImperial() {
        kilograms = Int((Double(pounds) / 2.20462).rounded())
    }
}

// MARK: - Preview

#Preview {
    MockOnboardingView()
}
