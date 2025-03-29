//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 29.03.25.
//

import SwiftUI

struct NameStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var name: String = ""

    var step: EnterNameStep

    var body: some View {
        VStack {
            titleView
            descriptionView
            nameInputView
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    private var descriptionView: some View {
        Text(step.description)
            .font(.headline)
            .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
            .multilineTextAlignment(.center)
    }

    private var nameInputView: some View {
        TextField("Enter your name", text: $name)
            .textFieldStyle(NameTextFieldStyle(colorPalette: viewModel.colorPalette))
            .padding()
    }
}

private struct NameTextFieldStyle: TextFieldStyle {
    var colorPalette: ColorPalette

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
    OnboardingView(
        configuration: .testData(),
        delegate: MockOnboardingDelegate(),
        colorPalette: .testData,
        outerScreen: { _ in
        }
    )
    .preferredColorScheme(.dark)
}
