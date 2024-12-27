//
//  SwiftUIView.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import SwiftUI

struct PrimeStepView: View {
    @EnvironmentObject private var viewModel: OnboardingViewModel

    @State private var isLoading = true
    @State private var discountedProduct: DiscountedProduct = .testData()

    var step: PrimeStep

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            titleView
            if let discount = discountedProduct.discount {
                VStack(spacing: 8) {
                    expiresInView
                    CountdownClockView(discount: discount, isRunning: !isLoading)
                }
                .redacted(reason: .placeholder, if: isLoading)
            }
            descriptionView
            Spacer()
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
        .background(.black)
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
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
    }

    private var expiresInView: some View {
        Text("Expires In", bundle: .module)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.secondary)
    }

    private var descriptionView: some View {
        Text(step.description)
            .font(.system(size: 46, weight: .bold))
            .minimumScaleFactor(0.5)
            .foregroundStyle(Color.accentColor)
            .multilineTextAlignment(.center)
    }

    private var priceView: some View {
        HStack {
            Text(discountedProduct.duration)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            VStack(alignment: .trailing) {
                Text(discountedProduct.discountedPrice)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(discountedProduct.monthlyPrice)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.gray)
                    Text(discountedProduct.monthlyPriceTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding()
        .foregroundStyle(.black)
        .background(Color(uiColor: .systemGray6))
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
            .tint(.secondary)
            .frame(maxWidth: .infinity)
    }

    private var privacyPolicy: some View {
        Link("Privacy", destination: discountedProduct.privacyPolicy)
            .tint(.secondary)
            .frame(maxWidth: .infinity)
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
