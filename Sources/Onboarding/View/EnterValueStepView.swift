//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import SwiftUI
import CoreUI

struct EnterValueStepView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @FocusState var isFocused: Bool

    @State var value: String = ""

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
        ScrollView {
            VStack(spacing: UIConstants.contentSpacing) {
                imageView
                VStack(spacing: UIConstants.headingSpacing) {
                    titleView
                    descriptionView
                }
                valueInputView
            }
            .padding(.vertical, UIConstants.vScreenPadding)
            .padding(.horizontal, UIConstants.hScreenPadding)
        }
        .bottomBar {
            Color.clear.frame(height: 50)
        }
        .scrollDismissesKeyboardCompat()
        .task {
            try? await Task.sleep(for: .seconds(1))
            isFocused = true
        }
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = step.image {
            OnboardingImage(image: image, bundle: viewModel.configuration.bundle)
                .aspectRatio(contentMode: image.contentMode)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
                .frame(maxWidth: .infinity)
                .fixedSizeCompat(horizontal: false, vertical: true)
        }
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

    private var valueInputView: some View {
        TextField(step.placeholder, text: $value)
            .focused($isFocused)
            .nameTextFieldStyleCompat(colorPalette: viewModel.colorPalette)
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

extension View {
    @ViewBuilder
    func nameTextFieldStyleCompat(colorPalette: any ColorPalette) -> some View {
        #if os(Android)
        nameTextFieldChrome(self, colorPalette: colorPalette)
        #else
        textFieldStyle(NameTextFieldStyle(colorPalette: colorPalette))
        #endif
    }
}

@ViewBuilder
private func nameTextFieldChrome<V: View>(_ view: V, colorPalette: any ColorPalette) -> some View {
    view
        .foregroundStyle(colorPalette.secondaryButtonForegroundColor)
        .padding()
        .background(colorPalette.secondaryButtonBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorPalette.secondaryButtonStrokeColor, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
}

#if !os(Android)
private struct NameTextFieldStyle: TextFieldStyle {
    var colorPalette: any ColorPalette

    func _body(configuration: TextField<Self._Label>) -> some View {
        nameTextFieldChrome(configuration, colorPalette: colorPalette)
    }
}
#endif

#if !os(Android)
#Preview {
    MockOnboardingView()
}
#endif
