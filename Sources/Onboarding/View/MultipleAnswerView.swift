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
        VStack {
            scrollView
            nextButton
        }
        .padding(.top, .progressBarHeight + .progressBarBottomPadding)
        .background(viewModel.colorPalette.backgroundColor)
    }

    private var scrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading) {
                    titleView
                    descriptionView
                }
                VStack(alignment: .leading, spacing: 12) {
                    ForEach($answers) { answer in
                        buttonView(answer: answer)
                    }
                }
            }
            .padding([.horizontal, .top])
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
            HStack {
                Text(answer.wrappedValue.value.title)
                Spacer()
                CheckBox(isChose: answer.isChose)
                    .allowsHitTesting(false)
            }
        }
        .buttonStyle(MultipleAnswerButtonStyle())
    }

    private var nextButton: some View {
        AsyncButton {
            await viewModel.onAnswer(answers: answers.filter(\.isChose).map(\.value))
        } label: {
            Text(step.buttonTitle)
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding([.horizontal, .bottom])
        .disabled(answers.isDisabled)
        .animation(.easeInOut, value: answers.isDisabled)
    }

}

private struct BoxModel: Identifiable {
    var id: StepAnswer { value }
    var isChose: Bool = false
    var value: StepAnswer
}

private extension Array where Element == BoxModel {

    var isDisabled: Bool {
        !contains(where: { element in element.isChose })
    }
}

#Preview {
    MultipleAnswerView(step: .testData())
        .preferredColorScheme(.dark)
}
