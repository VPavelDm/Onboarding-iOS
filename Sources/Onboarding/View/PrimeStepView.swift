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
    @State private var isRefuseButtonVisible = false
    @State private var discountedProduct: DiscountedProduct = .testData()

    @State private var isWarningShowed: Bool = false

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
                HStack {
                    termsOfUseView
                    refuseButton
                    privacyPolicy
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .animation(.easeInOut, value: isLoading)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorPalette.backgroundColor)
        .alert(step.warning.title, isPresented: $isWarningShowed) {
            confirmWarning
            cancelWarning
        } message: {
            Text(step.warning.description)
        }
        .task {
            do {
                try? await Task.sleep(for: .seconds(3))
                discountedProduct = try await viewModel.delegate.fetchDiscountedProduct()
                isLoading = false
                try? await Task.sleep(for: .seconds(3))
                isRefuseButtonVisible = true
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

    private var refuseButton: some View {
        Button {
            isWarningShowed = true
        } label: {
            Text(step.refuseAnswer.title)
                .foregroundStyle(colorPalette.grayButtonTextColor)
                .multilineTextAlignment(.center)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .opacity(isRefuseButtonVisible ? 1 : 0)
        .animation(.easeInOut, value: isRefuseButtonVisible)
    }

    private var confirmWarning: some View {
        Button(role: .destructive) {
            Task { @MainActor in
                await viewModel.onAnswer(answers: [step.refuseAnswer])
            }
        } label: {
            Text(step.warning.confirmButtonTitle)
        }
    }

    private var cancelWarning: some View {
        Button {
            Task { @MainActor in
                do {
                    isWarningShowed = false
                    try await viewModel.delegate.makePurchase(discountedProduct)
                    await viewModel.onAnswer(answers: [step.answer])
                } catch {
                    print(error.localizedDescription)
                }
            }
        } label: {
            Text(step.warning.cancelButtonTitle)
        }
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
