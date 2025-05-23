//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import SwiftUI

struct NameStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @FocusState private var isFocused: Bool

    @State private var name: String = ""

    var step: EnterNameStep

    var body: some View {
        VStack(alignment: .leading, spacing: .contentSpacing) {
            VStack(alignment: .leading, spacing: .headingSpacing) {
                titleView
                descriptionView
            }
            nameInputView
            Spacer()
            nextButton
        }
        .padding(.vertical, .vScreenPadding)
        .padding(.horizontal, .hScreenPadding)
        .task {
            try? await Task.sleep(for: .seconds(1))
            isFocused = true
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.title3)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .multilineTextAlignment(.leading)
        }
    }

    private var nameInputView: some View {
        TextField("Enter your name", text: $name)
            .focused($isFocused)
            .textFieldStyle(NameTextFieldStyle(colorPalette: viewModel.colorPalette))
            .textContentType(.name)
            .keyboardType(.namePhonePad)
            .submitLabel(.continue)
            .onSubmit {
                Task {
                    await onContinue()
                }
            }
    }

    private var nextButton: some View {
        AsyncButton {
            await onContinue()
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(name.isEmpty)
        .animation(.easeInOut, value: name.isEmpty)
    }

    private func onContinue() async {
        isFocused = false
        var step = step
        step.answer.payload = .string(name)
        await viewModel.onAnswer(answers: [step.answer])
    }
}

private struct NameTextFieldStyle: TextFieldStyle {
    var colorPalette: any ColorPalette

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundStyle(colorPalette.secondaryButtonForegroundColor)
            .padding()
            .background(colorPalette.secondaryButtonBackgroundColor)
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
