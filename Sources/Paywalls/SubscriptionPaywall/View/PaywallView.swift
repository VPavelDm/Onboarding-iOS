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

    private var content: some View {
        VStack(spacing: 16) {
            header.padding(.top, 44)
            Spacer(minLength: 0)
            planContext
            Spacer(minLength: 0)
            if showsFootnote {
                footnoteLabel
            }
            planSelector
            ctaButton
            if let declineTitle = dismiss?.declineTitle {
                declineButton(declineTitle)
            }
            PaywallFooterView(
                termsURL: configuration.termsURL,
                privacyURL: configuration.privacyURL,
                textColor: configuration.textColor,
                onRestore: handleRestore
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text(configuration.title)
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
            }
        }
    }

    /// Both variants stay mounted and only cross-fade: the ZStack keeps the taller
    /// view's height, so switching plans never shifts the layout below.
    private var planContext: some View {
        ZStack {
            PaywallFeaturesView(
                features: configuration.features,
                textColor: configuration.textColor,
                iconBackground: configuration.ctaBackground,
                iconColor: configuration.ctaForeground ?? .white
            )
            .opacity(viewModel.selectedHasTrial ? 0 : 1)
            if let days = viewModel.trialDays {
                PaywallTimelineView(
                    trialDays: days,
                    unlockBody: configuration.trialUnlockBody,
                    trialEndBody: configuration.trialEndBody,
                    textColor: configuration.textColor,
                    iconBackground: configuration.ctaBackground,
                    iconColor: configuration.ctaForeground ?? .white,
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
                .font(.title3.weight(.semibold))
                .foregroundStyle(configuration.textColor)
                .opacity(viewModel.selectedHasTrial ? 1 : 0)
            Text("Cancel anytime", bundle: .module)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(configuration.textColor.opacity(0.6))
                .opacity(viewModel.selectedHasTrial ? 0 : 1)
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
                        savingsBadge: viewModel.savingsBadge(for: plan),
                        selectionNamespace: selectionNamespace,
                        textColor: configuration.textColor,
                        accent: configuration.ctaBackground,
                        accentForeground: configuration.ctaForeground ?? .white,
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
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .frame(height: 96)
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
            foreground: configuration.ctaForeground
        ))
        .disabled(viewModel.isPurchasing || viewModel.isLoading || viewModel.isPendingApproval)
    }

    /// The host's CTA copy applies to the plain buy state; the retry and trial
    /// states keep the library's wording. The price-bearing variant wins when the
    /// selection's price is known, so the button names the charge.
    private var ctaTitle: String {
        guard viewModel.hasOfferings, !viewModel.selectedHasTrial else {
            return viewModel.ctaTitle
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
