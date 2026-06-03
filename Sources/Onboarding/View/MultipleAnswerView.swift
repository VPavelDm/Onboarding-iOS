//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI
import CoreUI

struct MultipleAnswerView: View {
    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var answers: [BoxModel]
    private let step: MultipleAnswerStep

    init(step: MultipleAnswerStep) {
        self.step = step
        self.answers = step.answers.map { answer in BoxModel(value: answer) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: UIConstants.contentSpacing) {
                imageView
                VStack(spacing: UIConstants.headingSpacing) {
                    titleView
                    descriptionView
                }
                VStack(alignment: .leading, spacing: UIConstants.buttonsSpacing) {
                    ForEach($answers) { answer in
                        buttonView(answer: answer)
                    }
                }
            }
            .padding(.vertical, UIConstants.vScreenPadding)
            .padding(.horizontal, UIConstants.hScreenPadding)
        }
        .bottomBar {
            nextButton
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
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

    private func buttonView(answer: Binding<BoxModel>) -> some View {
        Button {
            viewModel.playToggleFeedback()
            answer.wrappedValue.isChose.toggle()
        } label: {
            Text(answer.wrappedValue.value.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .applyRippleEffect()
        }
        .multipleAnswerButtonStyleCompat(colorPalette: viewModel.colorPalette, isSelected: answer.isChose.wrappedValue)
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: answers.filter(\.isChose).map(\.value))
        } label: {
            Text(step.buttonTitle)
                .applyRippleEffect()
        }
        .primaryButtonStyleCompat(colorPalette: viewModel.colorPalette)
        .revealBottomButton(!answers.isDisabled(step: step))
    }

}

struct BoxModel: Identifiable {
    var id: StepAnswer { value }
    var isChose: Bool = false
    var value: StepAnswer
}

private extension Array where Element == BoxModel {

    func isDisabled(step: MultipleAnswerStep) -> Bool {
        filter(\.isChose).count < step.minAnswersAmount
    }
}

#if !os(Android)
#Preview {
    MockOnboardingView()
}
#endif
