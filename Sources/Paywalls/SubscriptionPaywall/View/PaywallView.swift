//
//  PaywallView.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// A subscription (or lifetime) paywall: trial timeline (or feature list) over a plan
/// selector — or a single price card when the offering resolves to one plan — and a
/// single CTA. Hard by default: no close button, and `onUnlocked` fires only after a
/// successful purchase or restore. Pass `dismiss:` to make it a cart instead — a
/// delayed corner close and an optional named decline. Restore, Terms and Privacy
/// stay reachable in the footer, and a failed offerings fetch turns the CTA into a
/// retry so the screen can never become a dead end.
///
/// The view draws no background — it expects the host to provide one — and its text
/// is white by default, designed for dark backdrops; hosts on light backdrops set
/// `PaywallConfiguration.textColor`. App-specific copy comes in through
/// `PaywallConfiguration`.
public struct PaywallView: View {

    @State private var viewModel: PaywallViewModel
    @State private var showCloseButton: Bool
    @Environment(\.paywallCTAStyle) private var customCTAStyle
    @Namespace private var selectionNamespace

    private let configuration: PaywallConfiguration
    private let dismiss: PaywallDismissBehavior?
    private let onUnlocked: () -> Void

    public init(
        viewModel: PaywallViewModel,
        configuration: PaywallConfiguration,
        dismiss: PaywallDismissBehavior? = nil,
        onUnlocked: @escaping () -> Void
    ) {
        viewModel.configure(with: configuration)
        _viewModel = State(initialValue: viewModel)
        _showCloseButton = State(initialValue: (dismiss?.closeButtonDelay ?? .zero) <= .zero)
        self.configuration = configuration
        self.dismiss = dismiss
        self.onUnlocked = onUnlocked
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            content
            if dismiss != nil {
                PaywallCloseButton(textColor: configuration.textColor, action: handleClose)
                    .padding(.top, 16)
                    .padding(.trailing, 20)
                    .opacity(showCloseButton ? 1 : 0)
                    .allowsHitTesting(showCloseButton)
                    .animation(.easeIn(duration: 0.3), value: showCloseButton)
            }
        }
        .task { await viewModel.loadOfferings() }
        .task {
            guard let delay = dismiss?.closeButtonDelay, delay > .zero else { return }
            try? await Task.sleep(for: delay)
            showCloseButton = true
        }
        .paywallAlerts(
            showRestoreFailedAlert: $viewModel.showRestoreFailedAlert,
            showPendingApprovalAlert: $viewModel.showPendingApprovalAlert,
            purchaseError: $viewModel.purchaseError
        )
    }

    // MARK: - Subviews

    /// Scrolls only when the content is taller than the screen. The column is
    /// given the screen's height as a minimum, so on a phone where everything
    /// fits the two spacers centre the pitch between the header and the plans
    /// and the scroll view never moves; on a short phone (iPhone SE with the
    /// trial timeline or a four-row feature list) the column takes its natural
    /// height and scrolls. Before this the column was squeezed into the screen:
    /// the headline was cut to one line, the close button rode into the status
    /// bar and the footer fell off the bottom (2026-09-09).
    ///
    /// The reassurance line ("Cancel anytime" / "No payment due now") sits
    /// under the CTA since 2.10: above the tiles it floated alone in the gap
    /// under the pitch, and it belongs next to the button it reassures about.
    private var content: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    // With a mark the header is the tallest block on the page,
                    // so it starts lower and the mark sits below the status bar
                    // rather than beside the corner close.
                    if let gap = configuration.headerSpacing {
                        Spacer(minLength: configuration.headerSymbol == nil ? 44 : 56)
                        header
                        planContext
                            .padding(.top, gap)
                    } else {
                        header
                            .padding(.top, configuration.headerSymbol == nil ? 44 : 56)
                        Spacer(minLength: 24)
                        planContext
                    }
                    Spacer(minLength: 24)
                    planSelector
                    ctaButton
                        .padding(.top, 16)
                    if let declineTitle = dismiss?.declineTitle {
                        declineButton(declineTitle)
                            .padding(.top, 12)
                    }
                    if showsFootnote {
                        footnoteLabel
                            .padding(.top, 14)
                    }
                    PaywallFooterView(
                        termsURL: configuration.termsURL,
                        privacyURL: configuration.privacyURL,
                        textColor: configuration.textColor,
                        onRestore: handleRestore
                    )
                    .padding(.top, showsFootnote ? 6 : 14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geo.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            if let symbol = configuration.headerSymbol {
                PaywallMark(systemImage: symbol, tint: accent, size: 96)
                    .padding(.bottom, 18)
            }
            Text(title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(configuration.textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)

            if let subtitle = configuration.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(configuration.textColor.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
            }
        }
    }

    private var title: AttributedString {
        var title = AttributedString(configuration.title)
        if let word = configuration.titleHighlight, let range = title.range(of: word) {
            title[range].foregroundColor = accent
        }
        return title
    }

    private var accent: Color { configuration.accent ?? configuration.ctaBackground ?? .accentColor }
    private var accentForeground: Color { configuration.accentForeground ?? configuration.ctaForeground ?? .white }

    /// Both variants stay mounted and only cross-fade: the ZStack keeps the taller
    /// view's height, so switching plans never shifts the layout below.
    private var planContext: some View {
        ZStack {
            PaywallFeaturesView(
                features: configuration.features,
                alignment: configuration.featureAlignment,
                textColor: configuration.textColor,
                accent: accent,
                accentForeground: accentForeground,
                iconStyle: configuration.featureIconStyle
            )
            .opacity(viewModel.selectedHasTrial ? 0 : 1)
            if let days = viewModel.trialDays {
                PaywallTimelineView(
                    trialDays: days,
                    unlockBody: configuration.trialUnlockBody,
                    trialEndBody: configuration.trialEndBody,
                    textColor: configuration.textColor,
                    accent: accent,
                    accentForeground: accentForeground,
                    iconStyle: configuration.featureIconStyle,
                    midTitle: configuration.trialMidTitle,
                    midBody: configuration.trialMidBody,
                    midIcon: configuration.trialMidIcon
                )
                .opacity(viewModel.selectedHasTrial ? 1 : 0)
            }
        }
    }

    /// A lifetime unlock has nothing to cancel and nothing due later — the
    /// subscription footnote would only sow doubt, so it disappears entirely.
    private var showsFootnote: Bool {
        if viewModel.selectedPlan?.period == .lifetime { return false }
        if viewModel.selectedPlan == nil && configuration.expectsSinglePlan { return false }
        return true
    }

    /// Same trick as `planContext`: fonts don't interpolate, so the two labels
    /// cross-fade in a fixed-height ZStack instead of morphing one Text.
    private var footnoteLabel: some View {
        ZStack {
            Text("No payment due now", bundle: .module)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(configuration.textColor.opacity(0.85))
                .opacity(viewModel.selectedHasTrial ? 1 : 0)
            cancelAnytime
                .opacity(viewModel.selectedHasTrial ? 0 : 1)
        }
    }

    @ViewBuilder
    private var cancelAnytime: some View {
        if configuration.showsStoreAssurance {
            HStack(spacing: 16) {
                assurance(Text("Cancel anytime", bundle: .module), systemImage: "checkmark")
                assurance(Text("Secured by App Store", bundle: .module), systemImage: "checkmark.shield")
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(configuration.textColor.opacity(0.7))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        } else {
            Text("Cancel anytime", bundle: .module)
                .font(.footnote.weight(.medium))
                .foregroundStyle(configuration.textColor.opacity(0.55))
        }
    }

    private func assurance(_ label: Text, systemImage: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(accent)
            label
        }
    }

    @ViewBuilder
    private var planSelector: some View {
        if let plan = viewModel.plans.first, viewModel.plans.count == 1 {
            priceCard(for: plan)
        } else if viewModel.plans.isEmpty {
            if configuration.expectsSinglePlan {
                priceCard(for: nil)
            } else {
                HStack(spacing: 12) {
                    placeholderTile
                    placeholderTile
                }
            }
        } else {
            HStack(spacing: 12) {
                ForEach(viewModel.plans) { plan in
                    PaywallPlanTile(
                        plan: plan,
                        isSelected: viewModel.isSelected(plan),
                        tag: viewModel.tag(for: plan),
                        noteStyle: configuration.planNote,
                        selectionNamespace: selectionNamespace,
                        textColor: configuration.textColor,
                        accent: accent,
                        accentForeground: accentForeground,
                        savingsBackground: configuration.savingsTagBackground,
                        savingsForeground: configuration.savingsTagForeground,
                        popularBackground: configuration.popularTagBackground,
                        popularForeground: configuration.popularTagForeground,
                        selection: configuration.planSelection,
                        isCompact: viewModel.plans.count >= 3,
                        onSelect: {
                            withAnimation(.snappy(duration: 0.25)) { viewModel.selectPlan(plan) }
                        }
                    )
                }
            }
        }
    }

    private func priceCard(for plan: PaywallPlan?) -> some View {
        PaywallPriceCard(
            plan: plan,
            note: configuration.priceCardNote,
            textColor: configuration.textColor,
            background: configuration.cardBackground
        )
    }

    private var placeholderTile: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.ultraThinMaterial)
            .frame(height: 112)
            .opacity(0.4)
    }

    private var ctaButton: some View {
        Button(action: handleCTA) {
            Group {
                if viewModel.isPurchasing || viewModel.isLoading || viewModel.isPendingApproval {
                    ProgressView().tint(configuration.ctaForeground ?? .white)
                } else {
                    Text(ctaTitle)
                        .contentTransition(.opacity)
                }
            }
        }
        .buttonStyle(PaywallCTAButtonStyle(
            background: configuration.ctaBackground,
            foreground: configuration.ctaForeground,
            custom: customCTAStyle
        ))
        .disabled(viewModel.isPurchasing || viewModel.isLoading || viewModel.isPendingApproval)
    }

    /// The host's CTA copy applies to the buy states; the retry state keeps the
    /// library's wording, because it is about the fetch failing rather than about
    /// what is being bought. A trial selection takes `ctaTrialTitle`; otherwise the
    /// price-bearing variant wins when the selection's price is known, so the
    /// button names the charge.
    private var ctaTitle: String {
        guard viewModel.hasOfferings else { return viewModel.ctaTitle }
        if viewModel.selectedHasTrial {
            return configuration.ctaTrialTitle ?? viewModel.ctaTitle
        }
        if let withPrice = configuration.ctaTitleWithPrice, let plan = viewModel.selectedPlan {
            return withPrice(plan.localizedPrice)
        }
        return configuration.ctaTitle ?? viewModel.ctaTitle
    }

    private func declineButton(_ title: String) -> some View {
        Button(action: handleDecline) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(configuration.textColor.opacity(0.5))
                .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
        // Gated on the same flag as the corner ✕ — one "you may now leave"
        // moment, expressed two ways, so the dwell isn't quietly bypassed by
        // the named action.
        .opacity(showCloseButton ? 1 : 0)
        .allowsHitTesting(showCloseButton)
        .animation(.easeIn(duration: 0.3), value: showCloseButton)
    }

    // MARK: - Actions

    /// Retries the fetch while there is nothing to buy, otherwise buys the selection.
    private func handleCTA() {
        Task {
            guard viewModel.hasOfferings else {
                return await viewModel.loadOfferings()
            }
            if await viewModel.purchase() { onUnlocked() }
        }
    }

    private func handleRestore() {
        Task {
            if await viewModel.restorePurchases() { onUnlocked() }
        }
    }

    private func handleClose() {
        viewModel.userDismissed()
        dismiss?.onDismiss()
    }

    private func handleDecline() {
        viewModel.userDeclined()
        dismiss?.onDismiss()
    }
}
