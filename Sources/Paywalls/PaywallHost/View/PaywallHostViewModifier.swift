//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 04.05.25.
//

import SwiftUI
import Adapty
import AdaptyUI

private struct PaywallHostViewModifier: ViewModifier {

    private let viewModel: PaywallHostViewModel

    @State private var showRemoteConfigPaywall: AdaptyRemoteConfigPaywall?
    @State private var paywallConfiguration: AdaptyUI.PaywallConfiguration?

    @State private var alertItem: AdaptyAlertItem?

    @State private var showRating: Bool = false

    @Binding var isPresented: Bool
    private let close: () async -> Void

    init(isPresented: Binding<Bool>, placementID: String, delegate: any PaywallHostDelegate, close: @escaping () async -> Void) {
        self._isPresented = isPresented
        self.viewModel = PaywallHostViewModel(placementID: placementID, delegate: delegate)
        self.close = close
    }

    func body(content: Content) -> some View {
        VStack {
            content
                .background {
                    if let remoteConfig = showRemoteConfigPaywall {
                        Color.clear
                            .fullScreenCover(isPresented: $isPresented) {
                                Text("")
//                                PaywallView(
//                                    products: remoteConfig.products,
//                                    didPerformAction: didPerformAction(action:),
//                                    didStartPurchase: didStartPurchase(product:),
//                                    didFinishPurchase: didFinishPurchase(product:result:),
//                                    didFailPurchase: didFailPurchase(product:error:),
//                                    didStartRestore: didStartRestore,
//                                    didFinishRestore: didFinishRestore(profile:),
//                                    didFailRestore: didFailRestore(error:),
//                                    didFail: didFail(error:),
//                                    showAlertItem: $alertItem,
//                                    showAlertBuilder: alert(item:)
//                                )
//                                .wrapNavigationView()
                            }
                    }
                }
                .background {
                    if let paywallConfiguration {
                        Color.clear
                            .paywall(
                                isPresented: $isPresented,
                                paywallConfiguration: paywallConfiguration,
                                didPerformAction: didPerformAction(action:),
                                didStartPurchase: didStartPurchase(product:),
                                didFinishPurchase: didFinishPurchase(product:result:),
                                didFailPurchase: didFailPurchase(product:error:),
                                didStartRestore: didStartRestore,
                                didFinishRestore: didFinishRestore(profile:),
                                didFailRestore: didFailRestore(error:),
                                didFailRendering: didFailRendering(error:),
                                didFailLoadingProducts: didFailLoadingProducts(error:),
                                showAlertItem: $alertItem,
                                showAlertBuilder: alert(item:)
                            )
                    }
                }
                .ratingSheet(isPresented: $showRating)
                .onChange(of: isPresented) { [wasPresented = isPresented] nowPresented in
                    if wasPresented && !nowPresented {
                        Task { @MainActor in
                            await close()
                        }
                    } else if !wasPresented && nowPresented {
                        viewModel.delegate?.track(event: "trackPaywallShown", parameters: ["placementID": viewModel.placementID])
                    }
                }
        }
        .task {
            do {
                let configuration = try await viewModel.fetchPaywallConfiguration()
                switch configuration {
                case .paywallConfiguration(let configuration):
                    paywallConfiguration = configuration
                case .remoteConfig(let products, let paywall):
                    showRemoteConfigPaywall = AdaptyRemoteConfigPaywall(products: products, paywall: paywall)
                }
            } catch let error as AdaptyError {
                _ = didFailLoadingProducts(error: error)
            } catch {
                didFail(error: error)
            }
        }
    }

    func alert(item: AdaptyAlertItem) -> Alert {
        Alert(
            title: Text(item.title),
            message: Text(item.message),
            dismissButton: .cancel()
        )
    }

    func didPerformAction(action: AdaptyUI.Action) {
        switch action {
        case .close:
            viewModel.delegate?.track(event: "paywallCloseButtonTapped", parameters: ["placementID": viewModel.placementID])
            isPresented = false
        case .custom(let id):
            switch id {
            case "show_all_plans":
                viewModel.delegate?.track(event: "showMoreSubscriptionsClicked", parameters: ["placementID": viewModel.placementID])
            default:
                viewModel.delegate?.track(event: "customButtonTapped", parameters: [
                    "placementID": viewModel.placementID,
                    "id": id
                ])
            }
        case .openURL(let url):
            viewModel.delegate?.track(event: "openURLButtonTapped", parameters: ["placementID": viewModel.placementID])
            UIApplication.shared.open(url)
        }
    }

    func didStartPurchase(product: AdaptyPaywallProduct) {
        viewModel.delegate?.track(event: "trackContinueButtonTapped", parameters: [
            "placementID": viewModel.placementID,
            "productID": product.sk2Product?.id ?? ""
        ])
    }

    func didFinishPurchase(product: AdaptyPaywallProduct, result: AdaptyPurchaseResult) {
        Task {
            switch result {
            case .success:
                try await viewModel.delegate?.fetchSubscriptionStatus()
                viewModel.delegate?.track(event: "trackSubscriptionStarted", parameters: [
                    "placementID": viewModel.placementID,
                    "productID": product.sk2Product?.id ?? ""
                ])
                showRating = true
                isPresented = false
            case .pending:
                try await viewModel.delegate?.fetchSubscriptionStatus()
                viewModel.delegate?.track(event: "subscriptionPending", parameters: ["placementID": viewModel.placementID])
                isPresented = false
            case .userCancelled:
                viewModel.delegate?.track(event: "subscriptionPurchaseCancelled", parameters: ["placementID": viewModel.placementID])
            }
        }
    }

    func didFailPurchase(product: AdaptyPaywallProduct, error: AdaptyError) {
        viewModel.delegate?.track(event: "trackSubscriptionPurchaseError", parameters: [
            "placementID": viewModel.placementID,
            "error": error
        ])
        alertItem = .purchaseError
    }

    func didStartRestore() {
        viewModel.delegate?.track(event: "trackRestoreButtonTapped", parameters: ["placementID": viewModel.placementID])
    }

    func didFinishRestore(profile: AdaptyProfile) {
        Task { @MainActor in
            do {
                if profile.accessLevels["premium"]?.isActive == true {
                    try await viewModel.delegate?.fetchSubscriptionStatus()
                } else {
                    throw StoreError.restorePurchaseError
                }
                isPresented = false
            } catch {
                viewModel.delegate?.track(event: "restorePurchaseFailed", parameters: [
                    "placementID": viewModel.placementID,
                    "error": error
                ])
                alertItem = .restoreError
            }
        }
    }

    func didFailRestore(error: AdaptyError) {
        viewModel.delegate?.track(event: "restorePurchaseFailed", parameters: [
            "placementID": viewModel.placementID,
            "error": error
        ])
        alertItem = .restoreError
    }

    func didFailRendering(error: AdaptyError) {
        viewModel.delegate?.track(event: "didFailRenderingError", parameters: [
            "placementID": viewModel.placementID,
            "error": error
        ])
    }

    func didFailLoadingProducts(error: AdaptyError) -> Bool {
        viewModel.delegate?.track(event: "didFailLoadingProductsError", parameters: [
            "placementID": viewModel.placementID,
            "error": error
        ])
        return true
    }

    func didFail(error: Error) {
        viewModel.delegate?.track(event: "paywallUnexpectedError", parameters: [
            "placementID": viewModel.placementID,
            "error": error
        ])
    }
}

public extension View {

    func paywall(
        isPresented: Binding<Bool>,
        placementID: String,
        delegate: any PaywallHostDelegate,
        close: @escaping () async -> Void
    ) -> some View {
        modifier(PaywallHostViewModifier(isPresented: isPresented, placementID: placementID, delegate: delegate, close: close))
    }
}

