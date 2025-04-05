//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI
import CoreUI
import CoreHaptics

struct MultipleAnswerView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var answers: [BoxModel]
    private let step: MultipleAnswerStep

    init(step: MultipleAnswerStep) {
        self.step = step
        self.answers = step.answers.map { answer in BoxModel(value: answer) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    titleView
                    descriptionView
                }
                VStack(alignment: .leading, spacing: 12) {
                    ForEach($answers) { answer in
                        buttonView(answer: answer)
                    }
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom) {
            nextButton
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(viewModel.colorPalette.textColor)
    }

    @ViewBuilder
    private var descriptionView: some View {
        if let description = step.description {
            Text(description)
                .font(.headline)
                .foregroundStyle(viewModel.colorPalette.secondaryTextColor)
        }
    }

    private func buttonView(answer: Binding<BoxModel>) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            answer.wrappedValue.isChose.toggle()
        } label: {
            Text(answer.wrappedValue.value.title)
        }
        .buttonStyle(MultipleAnswerButtonStyle(isSelected: answer.isChose.wrappedValue))
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: answers.filter(\.isChose).map(\.value))
        } label: {
            Text(step.buttonTitle)
        }
        .buttonStyle(PrimaryButtonStyle())
        .opacity(answers.isDisabled(step: step) ? 0 : 1)
        .animation(.easeInOut, value: answers.isDisabled(step: step))
    }

}

private struct BoxModel: Identifiable {
    var id: StepAnswer { value }
    var isChose: Bool = false
    var value: StepAnswer
}

private extension Array where Element == BoxModel {

    func isDisabled(step: MultipleAnswerStep) -> Bool {
        filter(\.isChose).count < step.minAnswersAmount
    }
}

#Preview {
    MockOnboardingView()
}
