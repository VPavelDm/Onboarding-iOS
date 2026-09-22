//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 04.05.25.
//

import SwiftUI
import Adapty
import AdaptyUI
import CoreAnalytics

@MainActor
final class PaywallHostViewModel {

    // MARK: - Properties

    let placementID: String
    private let locale: Locale

    weak var delegate: PaywallHostDelegate?

    // MARK: - Inits

    init(placementID: String, delegate: PaywallHostDelegate, locale: Locale = .current) {
        self.placementID = placementID
        self.delegate = delegate
        self.locale = locale
    }

    // MARK: - Intents

    func fetchPaywallConfiguration() async throws -> AdaptyPaywallConfiguration {
        let paywall = try await Adapty.getPaywall(placementId: placementID, locale: locale.language.languageCode?.identifier ?? "en")
        if paywall.hasViewConfiguration {
            let configuration = try await AdaptyUI.getPaywallConfiguration(forPaywall: paywall)
            return .paywallConfiguration(configuration)
        } else {
            let products = try await Adapty.getPaywallProducts(paywall: paywall)
            return .remoteConfig(products, paywall)
        }
    }
}
