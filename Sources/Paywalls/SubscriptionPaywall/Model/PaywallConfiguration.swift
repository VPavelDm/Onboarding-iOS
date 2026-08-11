//
//  PaywallConfiguration.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import Foundation
import SwiftUI

/// The app-specific copy, links, and palette shown on the paywall. Everything the
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
    /// An optional line under the headline, for copy that ties the features to the
    /// price (e.g. "All three come with Futura Forever.").
    public var subtitle: String?
    /// The feature list shown for plans without a trial.
    public var features: [Feature]
    /// Body of the trial timeline's first step ("Today — full access"): what the user
    /// gets right now, in the app's own words.
    public var trialUnlockBody: String
    /// Body of the trial timeline's last step ("Day N — trial ends"). Defaults to a
    /// localized "Your subscription begins so your streak keeps going."
    public var trialEndBody: String
    /// Overrides the CTA title when the selected plan has no trial (e.g. "Unlock
    /// forever"). Trial and retry CTAs keep the library's wording.
    public var ctaTitle: String?
    /// The line under the product name on the single-plan price card. Defaults to a
    /// localized "One payment. No subscription, ever." for lifetime plans and the
    /// billing cadence for subscriptions.
    public var priceCardNote: String?
    public var termsURL: URL?
    public var privacyURL: URL?

    /// The screen's text color. White by default — the classic dark-backdrop paywall.
    /// Hosts with a light backdrop pass their dark text color; every label, footer
    /// link, and hairline derives its opacity from this.
    public var textColor: Color
    /// The CTA's fill and label colors. Default to the accent color and `.primary`.
    public var ctaBackground: Color?
    public var ctaForeground: Color?
    /// A solid fill for the single-plan price card (e.g. white on a cream backdrop).
    /// When nil the card gets the same material treatment as the plan tiles.
    public var cardBackground: Color?
    /// True when the placement is expected to resolve to a single plan — draws the
    /// loading placeholder as one price card instead of two tiles, so the layout
    /// doesn't jump when the real offering lands.
    public var expectsSinglePlan: Bool

    public init(
        title: String? = nil,
        subtitle: String? = nil,
        features: [Feature],
        trialUnlockBody: String,
        trialEndBody: String? = nil,
        ctaTitle: String? = nil,
        priceCardNote: String? = nil,
        termsURL: URL? = nil,
        privacyURL: URL? = nil,
        textColor: Color = .white,
        ctaBackground: Color? = nil,
        ctaForeground: Color? = nil,
        cardBackground: Color? = nil,
        expectsSinglePlan: Bool = false
    ) {
        self.title = title ?? String(localized: "Unlock your full plan", bundle: .module)
        self.subtitle = subtitle
        self.features = features
        self.trialUnlockBody = trialUnlockBody
        self.trialEndBody = trialEndBody
            ?? String(localized: "Your subscription begins so your streak keeps going.", bundle: .module)
        self.ctaTitle = ctaTitle
        self.priceCardNote = priceCardNote
        self.termsURL = termsURL
        self.privacyURL = privacyURL
        self.textColor = textColor
        self.ctaBackground = ctaBackground
        self.ctaForeground = ctaForeground
        self.cardBackground = cardBackground
        self.expectsSinglePlan = expectsSinglePlan
    }
}
