#if !os(Android)
//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import SwiftUI
import CoreUI

struct DiscountWheelSuccessView: View {

    @Environment(OnboardingViewModel.self) var viewModel: OnboardingViewModel

    @State var size: CGSize = .zero

    @Binding var isPresented: Bool
    var nextStepID: StepID?

    var body: some View {
        VStack(spacing: 32) {
            VStack {
                titleView
                descriptionView
            }
            .padding([.horizontal, .top])
            takeButton
        }
        .padding()
        .background(.black)
        .readSize(size: $size)
        .presentationDetents([.height(size.height)])
        .interactiveDismissDisabled()
    }

    private var titleView: some View {
        Text(localized("discountWheel.successTitle"))
            .font(.title2.bold())
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionView: some View {
        Text(viewModel.format(string: localized("discountWheel.successDescription")))
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var takeButton: some View {
        AsyncButton {
            isPresented = false
            await viewModel.onAnswer(answers: [makeAnswer()])
        } label: {
            Text(localized("discountWheel.answerTitle"))
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: viewModel.colorPalette))
    }

    private func localized(_ key: String) -> String {
        viewModel.localizer.localize(key)
    }

    private func makeAnswer() -> StepAnswer {
        StepAnswer(
            title: localized("discountWheel.answerTitle"),
            icon: nil,
            nextStepID: nextStepID,
            payload: nil
        )
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            DiscountWheelSuccessView(isPresented: .constant(true), nextStepID: nil)
        }
}
#endif
