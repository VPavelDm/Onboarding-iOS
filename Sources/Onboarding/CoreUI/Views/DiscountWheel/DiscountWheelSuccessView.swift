//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import SwiftUI

struct DiscountWheelSuccessView: View {
    @Environment(\.colorPalette) private var colorPalette

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
        .background(colorPalette.backgroundColor)
        .readSize(size: $size)
        .presentationDetents([.height(size.height)])
        .interactiveDismissDisabled()
    }

    private var titleView: some View {
        Text(step.successTitle)
            .font(.title2.bold())
            .foregroundStyle(colorPalette.primaryTextColor)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionView: some View {
        Text(step.successDescription)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(colorPalette.secondaryTextColor)
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
