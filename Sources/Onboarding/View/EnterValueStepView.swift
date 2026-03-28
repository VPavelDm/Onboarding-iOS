//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import SwiftUI
import CoreUI

struct EnterValueStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @FocusState private var isFocused: Bool

    @State private var value: String = ""

    private var textContentType: UITextContentType? {
        switch step.valueType {
        case "name":
            UITextContentType.name
        default:
            nil
        }
    }

    private var keyboardType: UIKeyboardType {
        switch step.valueType {
        case "name":
            UIKeyboardType.namePhonePad
        case "number":
            UIKeyboardType.numberPad
        default:
            UIKeyboardType.default
        }
    }

    var step: EnterValueStep

    var body: some View {
        VStack(spacing: .contentSpacing) {
            imageView
            VStack(spacing: .headingSpacing) {
                titleView
                descriptionView
            }
            valueInputView
            Spacer()
        }
        .padding(.vertical, .vScreenPadding)
        .padding(.horizontal, .hScreenPadding)
        .ignoresSafeArea(.keyboard)
        .task {
            try? await Task.sleep(for: .seconds(1))
            isFocused = true
        }
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .frame(maxWidth: .infinity)
        }
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

    private var valueInputView: some View {
        TextField(step.placeholder, text: $value)
            .focused($isFocused)
            .textFieldStyle(NameTextFieldStyle(colorPalette: viewModel.colorPalette))
            .textContentType(textContentType)
            .keyboardType(keyboardType)
            .submitLabel(.next)
            .onSubmit {
                Task {
                    await onContinue()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    skipToolbarButton
                    Spacer()
                    continueToolbarButton
                }
            }
    }

    @ViewBuilder
    private var skipToolbarButton: some View {
        if step.skipAnswer != nil {
            Button("Skip") {
                Task { await onContinue() }
            }
        }
    }

    private var continueToolbarButton: some View {
        Button(step.primaryAnswer.title) {
            Task { await onContinue() }
        }
        .fontWeight(.semibold)
        .disabled(value.isEmpty)
    }

    private func onContinue() async {
        if let skipAnswer = step.skipAnswer, value.isEmpty {
            isFocused = false
            await viewModel.onAnswer(answers: [skipAnswer])
        } else {
            isFocused = false
            var step = step
            step.primaryAnswer.payload = .string(value)
            await viewModel.onAnswer(answers: [step.primaryAnswer])
        }
    }
}

private struct NameTextFieldStyle: TextFieldStyle {
    var colorPalette: any ColorPalette

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundStyle(colorPalette.secondaryButtonForegroundColor)
            .padding()
            .background(colorPalette.secondaryButtonBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colorPalette.secondaryButtonStrokeColor, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    MockOnboardingView()
}
