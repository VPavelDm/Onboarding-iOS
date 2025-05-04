//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.03.25.
//

import SwiftUI
import CoreUI

struct DiscountPaywallView: View {
    @StateObject private var viewModel = DiscountPaywallViewModel()

    @State private var isLoading = true
    @State private var discountedProduct: DiscountProduct = .testData()

    var info: DiscountPaywallInfo
    var fetchDiscountedProduct: () async throws -> DiscountProduct
    var makePurchase: (DiscountProduct) async throws -> Void
    var onClose: () async -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            titleView
            VStack(spacing: 8) {
                expiresInView
                CountdownClockView(discount: $discountedProduct.discount)
            }
            VStack(spacing: 6) {
                descriptionView
                discountMonthlyView
                    .redacted(reason: .placeholder, if: isLoading)
            }
            Spacer()
            VStack(spacing: 16) {
                priceView
                VStack(spacing: 12) {
                    continueButton
                    closeButton
                }
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
                discountedProduct = try await fetchDiscountedProduct()
                isLoading = false
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private var titleView: some View {
        Text(info.title)
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
        Text(info.description)
            .font(.system(size: 46, weight: .bold))
            .minimumScaleFactor(0.5)
            .foregroundStyle(Color.accentColor)
            .multilineTextAlignment(.center)
    }

    private var discountMonthlyView: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text("\(discountedProduct.originalMonthlyPrice)")
                .strikethrough(!isLoading)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.red)
            Text(discountedProduct.monthlyPrice)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            Text(discountedProduct.monthlyPriceTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var priceView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(discountedProduct.duration)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(discountedProduct.originalAnnualPrice)
                        .strikethrough(!isLoading)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.gray)
                    Text(discountedProduct.discountedPrice)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.tint)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(discountedProduct.monthlyPrice)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Text(discountedProduct.monthlyPriceTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
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
                try await makePurchase(discountedProduct)
            } catch {
                print(error.localizedDescription)
            }
        } label: {
            Text(info.buttonText)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isLoading)
    }

    private var closeButton: some View {
        AsyncButton {
            await onClose()
        } label: {
            Text("No Gift due now", bundle: .module)
        }
        .buttonStyle(SimpleButtonStyle())
    }

    private var termsOfUseView: some View {
        Link("Terms", destination: discountedProduct.termsOfUse)
            .tint(.secondary)
            .frame(maxWidth: .infinity)
            .buttonStyle(SimpleButtonStyle())
    }

    private var privacyPolicy: some View {
        Link("Privacy", destination: discountedProduct.privacyPolicy)
            .tint(.secondary)
            .frame(maxWidth: .infinity)
            .buttonStyle(SimpleButtonStyle())
    }
}
