//
//  OfferConfiguration.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import SwiftUI

/// The special offer's dress, as data, modelled on `PaywallConfiguration`:
/// the artwork, the badge, the wording around the figures and the colours.
/// Every string comes in already localized by the host. The figures
/// themselves (percent off, the struck-through price, the price per day) the
/// package works out from the plan (`OfferPitch`).
///
/// The CTA is drawn in `ctaBackground` / `ctaForeground`, or in the host's
/// own style from `paywallCTAButtonStyle(_:)`, as on `PaywallView`.
public struct OfferConfiguration {

    /// The picture across the top of the screen, fading into the page. The
    /// host builds the `Image`, so its assets stay in the app.
    public var artwork: Image?
    /// The pill over the figures ("HALLOWEEN SPECIAL") and its SF Symbol.
    public var badgeTitle: String
    public var badgeSymbol: String?
    /// The word under the percent, in display type ("OFF").
    public var offTitle: String
    /// The clock's line, with `{time}` for what is left ("Spooky deal ends
    /// in {time}").
    public var endsInTemplate: String
    /// The price line per cadence, with `{old}` for the struck-through price
    /// and `{new}` for the plan's ("Just {old} {new} per year"). A cadence
    /// without a template shows no price line.
    public var priceLineTemplates: [PaywallPlan.Period: String]
    /// The line under it, with `{price}` for the price per day ("(less than
    /// {price} per day)"). Nil shows none.
    public var perDayTemplate: String?
    /// Quiet words above the CTA ("Auto-renewable. Cancel anytime"). Nil
    /// shows none.
    public var renewalNote: String?
    public var ctaTitle: String
    /// The alerts' messages. Nil keeps the package's own.
    public var purchaseFailedMessage: String?
    public var restoreFailedMessage: String?
    public var termsURL: URL?
    public var privacyURL: URL?

    /// The page behind the artwork and the copy.
    public var backgroundColor: Color
    /// The copy's colour; every quieter label derives its opacity from it.
    public var textColor: Color
    /// The percent, the badge, the clock and the price per day. Nil follows
    /// the CTA colour.
    public var accent: Color?
    public var ctaBackground: Color?
    public var ctaForeground: Color?
    public var closeButtonStyle: PaywallConfiguration.CloseButtonStyle
    /// Below this height (the screen's own) the display type is smaller so
    /// the CTA stays in reach without scrolling on an iPhone SE (647 pt).
    /// Nil keeps one size at every height.
    public var compactHeight: CGFloat?

    public init(
        artwork: Image? = nil,
        badgeTitle: String,
        badgeSymbol: String? = nil,
        offTitle: String,
        endsInTemplate: String,
        priceLineTemplates: [PaywallPlan.Period: String],
        perDayTemplate: String? = nil,
        renewalNote: String? = nil,
        ctaTitle: String,
        purchaseFailedMessage: String? = nil,
        restoreFailedMessage: String? = nil,
        termsURL: URL? = nil,
        privacyURL: URL? = nil,
        backgroundColor: Color = .black,
        textColor: Color = .white,
        accent: Color? = nil,
        ctaBackground: Color? = nil,
        ctaForeground: Color? = nil,
        closeButtonStyle: PaywallConfiguration.CloseButtonStyle = .scrim,
        compactHeight: CGFloat? = nil
    ) {
        self.artwork = artwork
        self.badgeTitle = badgeTitle
        self.badgeSymbol = badgeSymbol
        self.offTitle = offTitle
        self.endsInTemplate = endsInTemplate
        self.priceLineTemplates = priceLineTemplates
        self.perDayTemplate = perDayTemplate
        self.renewalNote = renewalNote
        self.ctaTitle = ctaTitle
        self.purchaseFailedMessage = purchaseFailedMessage
        self.restoreFailedMessage = restoreFailedMessage
        self.termsURL = termsURL
        self.privacyURL = privacyURL
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.accent = accent
        self.ctaBackground = ctaBackground
        self.ctaForeground = ctaForeground
        self.closeButtonStyle = closeButtonStyle
        self.compactHeight = compactHeight
    }

    var resolvedAccent: Color { accent ?? ctaBackground ?? .accentColor }
}
