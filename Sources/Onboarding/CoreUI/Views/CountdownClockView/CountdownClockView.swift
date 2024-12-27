//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 24.12.24.
//

import SwiftUI
import Combine

struct CountdownClockView: View {

    @StateObject private var viewModel = CountdownClockViewModel()
    @Binding var discount: DiscountedProduct.Discount
    let isRunning: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(viewModel.timeComponents.indices, id: \.self) { index in
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(viewModel.timeComponents[index].digits.indices, id: \.self) { dIndex in
                            CardView(text: "\(viewModel.timeComponents[index].digits[dIndex])")
                        }
                    }
                    labelView(viewModel.timeComponents[index].label)
                }
                if index < viewModel.timeComponents.count - 1 {
                    dotsView
                }
            }
        }
        .onChange(of: isRunning) { [wasRunning = isRunning] isRunning in
            guard !wasRunning && isRunning else { return }
            viewModel.startTimer(discount: discount)
        }
    }

    private var dotsView: some View {
        VStack(spacing: 2) {
            Circle()
                .frame(width: 4, height: 4)
                .foregroundStyle(Color.secondary)
            Circle()
                .frame(width: 4, height: 4)
                .foregroundStyle(Color.secondary)
        }
        .padding(.top, 11)
    }

    private func labelView(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.secondary)
    }
}

private extension CountdownClockView {

    struct CardView: View {

        var text: String

        var body: some View {
            Text(text)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.primary)
                .animation(.easeInOut, value: text)
                .contentTransition(.numericText(countsDown: true))
                .frame(width: 24, height: 32)
                .clipped()
                .background(Color(uiColor: .systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

#Preview {
    PrimeStepView(step: .testData())
        .environmentObject(OnboardingViewModel(
            configuration: .testData(),
            delegate: MockOnboardingDelegate()
        ))
        .preferredColorScheme(.dark)
}
