//
//  PaywallView.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// A hard subscription paywall: trial timeline (or feature list) over a plan selector
/// and a single CTA. There is no close button, and `onUnlocked` fires only after a
/// successful purchase or restore. Restore, Terms and Privacy stay reachable in the
/// footer, and a failed offerings fetch turns the CTA into a retry so the screen can
/// never become a dead end.
///
/// The view draws no background — it expects the host to provide one — and its text
/// is white, designed for dark backdrops. App-specific copy comes in through
/// `PaywallConfiguration`.
public struct PaywallView: View {

    @State private var viewModel: PaywallViewModel
    @Namespace private var selectionNamespace

    private let configuration: PaywallConfiguration
    private let onUnlocked: () -> Void

    public init(
        viewModel: PaywallViewModel,
        configuration: PaywallConfiguration,
        onUnlocked: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.configuration = configuration
        self.onUnlocked = onUnlocked
    }

    public var body: some View {
        content
            .task { await viewModel.loadOfferings() }
            .paywallAlerts(
                showRestoreFailedAlert: $viewModel.showRestoreFailedAlert,
                showPendingApprovalAlert: $viewModel.showPendingApprovalAlert,
                purchaseError: $viewModel.purchaseError
            )
    }

    // MARK: - Subviews

    private var content: some View {
        VStack(spacing: 16) {
            title.padding(.top, 44)
            Spacer(minLength: 0)
            planContext
            Spacer(minLength: 0)
            footnoteLabel
            planSelector
            ctaButton
            PaywallFooterView(
                termsURL: configuration.termsURL,
                privacyURL: configuration.privacyURL,
                onRestore: handleRestore
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    private var title: some View {
        Text(configuration.title)
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .frame(maxWidth: .infinity)
    }

    /// Both variants stay mounted and only cross-fade: the ZStack keeps the taller
    /// view's height, so switching plans never shifts the layout below.
    private var planContext: some View {
        ZStack {
            PaywallFeaturesView(features: configuration.features)
                .opacity(viewModel.selectedHasTrial ? 0 : 1)
            if let days = viewModel.trialDays {
                PaywallTimelineView(
                    trialDays: days,
                    unlockBody: configuration.trialUnlockBody,
                    trialEndBody: configuration.trialEndBody
                )
                .opacity(viewModel.selectedHasTrial ? 1 : 0)
            }
        }
    }

    /// Same trick as `planContext`: fonts don't interpolate, so the two labels
    /// cross-fade in a fixed-height ZStack instead of morphing one Text.
    private var footnoteLabel: some View {
        ZStack {
            Text("No payment due now", bundle: .module)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .opacity(viewModel.selectedHasTrial ? 1 : 0)
            Text("Cancel anytime", bundle: .module)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.6))
                .opacity(viewModel.selectedHasTrial ? 0 : 1)
        }
    }

    @ViewBuilder
    private var planSelector: some View {
        if viewModel.plans.isEmpty {
            HStack(spacing: 12) {
                placeholderTile
                placeholderTile
            }
        } else {
            HStack(spacing: 12) {
                ForEach(viewModel.plans) { plan in
                    PaywallPlanTile(
                        plan: plan,
                        isSelected: viewModel.isSelected(plan),
                        savingsBadge: viewModel.savingsBadge(for: plan),
                        selectionNamespace: selectionNamespace,
                        onSelect: {
                            withAnimation(.snappy(duration: 0.25)) { viewModel.selectPlan(plan) }
                        }
                    )
                }
            }
        }
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
                    ProgressView().tint(.white)
                } else {
                    Text(viewModel.ctaTitle)
                        .contentTransition(.opacity)
                }
            }
        }
        .buttonStyle(PaywallCTAButtonStyle())
        .disabled(viewModel.isPurchasing || viewModel.isLoading || viewModel.isPendingApproval)
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
}
