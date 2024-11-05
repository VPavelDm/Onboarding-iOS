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
            featuresView
            VStack(spacing: 16) {
                priceView
                continueButton
                HStack {
                    termsOfUseView
                    privacyPolicy
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .animation(.easeInOut, value: isLoading)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorPalette.backgroundColor)
        .task {
            do {
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

    private var featuresView: some View {
        VStack(alignment: .leading) {
            ForEach(step.features.indices, id: \.self) { index in
                Text("‧ \(step.features[index])")
                    .foregroundStyle(colorPalette.secondaryTextColor)
                    .font(.system(size: 18, weight: .medium))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var priceView: some View {
        HStack {
            Text(discountedProduct.duration)
                .font(.system(size: 24, weight: .bold))
            Spacer()
            VStack(alignment: .trailing) {
                Text(discountedProduct.discountedPrice)
                    .font(.system(size: 24, weight: .bold))
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(discountedProduct.monthlyPrice)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(colorPalette.grayButtonTextColor)
                    Text(discountedProduct.monthlyPriceTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(colorPalette.grayButtonTextColor)
                }
            }
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

    private var termsOfUseView: some View {
        Link("Terms", destination: discountedProduct.termsOfUse)
            .tint(colorPalette.grayButtonTextColor)
            .frame(maxWidth: .infinity)
    }

    private var privacyPolicy: some View {
        Link("Privacy", destination: discountedProduct.privacyPolicy)
            .tint(colorPalette.grayButtonTextColor)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    PrimeStepView(step: .testData())
        .environmentObject(OnboardingViewModel(
            configuration: .testData(),
            delegate: MockOnboardingDelegate()
        ))
}
