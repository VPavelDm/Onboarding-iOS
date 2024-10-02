//
//  SwiftUIView.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import SwiftUI

struct PrimeStepView: View {
    @Environment(\.colorPalette) private var colorPalette
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var isLoading = true
    @State private var discountedProduct: DiscountedProduct = .testData()

    var step: PrimeStep

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            titleView
            descriptionView
            Spacer()
            VStack(spacing: 16) {
                priceView
                continueButton
            }
        }
        .animation(.easeInOut, value: isLoading)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorPalette.backgroundColor)
        .task {
            do {
                try? await Task.sleep(for: .seconds(3))
                discountedProduct = try await viewModel.delegate.fetchDiscountedProduct()
                isLoading = false
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private var titleView: some View {
        Text(step.title)
            .font(.title.bold())
            .foregroundStyle(colorPalette.primaryTextColor)
            .multilineTextAlignment(.center)
    }

    private var descriptionView: some View {
        Text(step.description)
            .font(.system(size: 46, weight: .bold))
            .foregroundStyle(colorPalette.primaryButtonBackgroundColor)
            .multilineTextAlignment(.center)
    }

    private var priceView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(discountedProduct.duration)
                    .font(.system(size: 24, weight: .bold))
                HStack {
                    Text(discountedProduct.originalPrice)
                        .strikethrough()
                    Text(discountedProduct.discountedPrice)
                }
            }
            Spacer()
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(discountedProduct.monthlyPrice)
                    .font(.system(size: 24, weight: .bold))
                Text(discountedProduct.monthlyPriceTitle)
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(colorPalette.discountSliceGiftColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
        .foregroundStyle(colorPalette.secondaryButtonTextColor)
        .background(colorPalette.secondaryButtonBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .redacted(reason: .placeholder, if: isLoading)
    }

    private var continueButton: some View {
        AsyncButton {
            do {
                try await viewModel.delegate.makePurchase(discountedProduct)
                await viewModel.onAnswer(answers: [step.answer])
            } catch {
                print(error.localizedDescription)
            }
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isLoading)
    }
}

#Preview {
    PrimeStepView(step: .testData())
        .environmentObject(OnboardingViewModel(
            configuration: .testData(),
            delegate: MockOnboardingDelegate()
        ))
}
