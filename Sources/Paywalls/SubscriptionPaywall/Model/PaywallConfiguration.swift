//
//  PaywallConfiguration.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import Foundation

/// The app-specific copy and links shown on the subscription paywall. Everything the
/// library can phrase generically (CTA, plan tiles, alerts, timeline chrome) lives in
/// the module's string catalog; everything that sells the host app comes in here,
/// already localized by the host.
public struct PaywallConfiguration: Sendable {

    /// One row of the feature list shown when the selected plan has no free trial.
    public struct Feature: Hashable, Sendable {
        public let title: String
        public let subtitle: String

        public init(title: String, subtitle: String) {
            self.title = title
            self.subtitle = subtitle
        }
    }

    /// The headline. Defaults to a localized "Unlock your full plan".
    public var title: String
    /// The feature list shown for plans without a trial.
    public var features: [Feature]
    /// Body of the trial timeline's first step ("Today — full access"): what the user
    /// gets right now, in the app's own words.
    public var trialUnlockBody: String
    /// Body of the trial timeline's last step ("Day N — trial ends"). Defaults to a
    /// localized "Your subscription begins so your streak keeps going."
    public var trialEndBody: String
    public var termsURL: URL?
    public var privacyURL: URL?

    public init(
        title: String? = nil,
        features: [Feature],
        trialUnlockBody: String,
        trialEndBody: String? = nil,
        termsURL: URL? = nil,
        privacyURL: URL? = nil
    ) {
        self.title = title ?? String(localized: "Unlock your full plan", bundle: .module)
        self.features = features
        self.trialUnlockBody = trialUnlockBody
        self.trialEndBody = trialEndBody
            ?? String(localized: "Your subscription begins so your streak keeps going.", bundle: .module)
        self.termsURL = termsURL
        self.privacyURL = privacyURL
    }
}
