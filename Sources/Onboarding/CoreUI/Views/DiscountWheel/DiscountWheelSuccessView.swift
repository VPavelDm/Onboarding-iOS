//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import SwiftUI
import CoreUI

struct DiscountWheelSuccessView: View {

    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var size: CGSize = .zero

    @Binding var isPresented: Bool
    var step: DiscountWheelStep

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
        Text(step.successTitle)
            .font(.title2.bold())
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionView: some View {
        Text(viewModel.format(string: step.successDescription))
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var takeButton: some View {
        AsyncButton {
            isPresented = false
            await viewModel.onAnswer(answers: [step.answer])
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            DiscountWheelSuccessView(isPresented: .constant(true), step: .testData())
        }
}
