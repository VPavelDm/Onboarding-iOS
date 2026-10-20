//
//  PaywallViewModel.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI
import StoreKit

/// Owns the paywall state: the offerings, the selected plan, and the purchase/restore
/// flow. The default selection is the host's featured plan, else the plan that offers
/// a free trial (if any), else the best-value plan. All store work goes through the
/// injected service; analytics through the injected `track` closure.
@MainActor
@Observable
public final class PaywallViewModel {

    private(set) var offerings: PaywallOfferings?
    private(set) var selectedPlanID: String?
    private(set) var isPurchasing = false
    private(set) var isLoading = false
    /// True after a purchase went pending (Ask to Buy / deferred payment). Keeps the
    /// CTA in its progress state so a second purchase can't be started; the unlock
    /// arrives out of band once the purchase is approved.
    private(set) var isPendingApproval = false
    /// True when the last offerings fetch failed — the paywall offers a retry instead
    /// of a dead CTA, because there is no way past it without a purchase.
    private(set) var loadFailed = false
    var purchaseError: String?
    var showRestoreFailedAlert = false
    var showPendingApprovalAlert = false

    /// The host's plan choices from `PaywallConfiguration`, handed over by the view.
    private var featuredPeriod: PaywallPlan.Period?
    /// Set by `PaywallTabsView`: the cadence chosen on another tab, which this
    /// one opens on when it sells it, over the featured plan.
    var preferredPeriod: PaywallPlan.Period?
    private var savingsTags: PaywallConfiguration.SavingsTags = .everyCheaperPlan
    private var regularPricePeriods: Set<PaywallPlan.Period> = []

    var hasOfferings: Bool { offerings != nil }
    var plans: [PaywallPlan] { offerings?.plans ?? [] }

    var selectedPlan: PaywallPlan? {
        plans.first { $0.id == selectedPlanID }
    }

    /// True when the selected plan starts with a free trial — drives the timeline,
    /// the "no payment" label, and the CTA wording.
    var selectedHasTrial: Bool { selectedPlan?.hasFreeTrial ?? false }

    /// The selected plan's paid first period, when it has one.
    var selectedIntroOffer: PaywallIntroOffer? { selectedPlan?.introOffer }

    /// Trial length of the offering's trial plan (not the selection), so the timeline
    /// can stay mounted and cross-fade in place while the selection changes.
    var trialDays: Int? { plans.first { $0.hasFreeTrial }?.freeTrialDays }

    var ctaTitle: String {
        guard hasOfferings else { return String(localized: "Retry", bundle: .module) }
        guard selectedHasTrial else { return String(localized: "Continue", bundle: .module) }
        if let days = selectedPlan?.freeTrialDays {
            return String(localized: "Try \(days) Days Free", bundle: .module)
        }
        return String(localized: "Start my free trial", bundle: .module)
    }

    /// The featured plan says "Popular"; otherwise a plan that saves says by how
    /// much, unless the host keeps that tag to the biggest saving.
    func tag(for plan: PaywallPlan) -> PaywallPlanTag? {
        if plan.period == featuredPeriod { return .popular }
        guard let offerings, let percent = offerings.savingsPercent(for: plan) else { return nil }
        if savingsTags == .hidden { return nil }
        if savingsTags == .biggestSavingOnly, !offerings.isBiggestSaving(plan) { return nil }
        return .savings(percent)
    }

    /// Twice `plan`'s price with its cents at 99 ($59.99 → $119.99),
    /// formatted like it, to strike through before it when the host lists the
    /// plan's period. Until 4.6 it was the plan's length at the priciest
    /// plan's rate (a year of weekly, ~~$312.34~~), which read as an
    /// implausible discount (Pavel, 2026-10-07).
    func regularPrice(for plan: PaywallPlan) -> String? {
        guard regularPricePeriods.contains(plan.period) else { return nil }
        return plan.localized(plan.endingIn99(plan.price * Self.regularPriceMarkup))
    }

    /// How many times its own price a plan's struck-through price is.
    static let regularPriceMarkup = 2.0

    func configure(with configuration: PaywallConfiguration) {
        featuredPeriod = configuration.featuredPeriod
        savingsTags = configuration.savingsTags
        regularPricePeriods = configuration.regularPricePeriods
    }

    func isSelected(_ plan: PaywallPlan) -> Bool { plan.id == selectedPlanID }

    // MARK: - Dependencies

    private let service: PaywallServiceProtocol
    private let source: String
    private let track: @MainActor (String, [String: Any]) -> Void

    public init(
        service: PaywallServiceProtocol,
        source: String,
        track: @escaping @MainActor (String, [String: Any]) -> Void = { _, _ in }
    ) {
        self.service = service
        self.source = source
        self.track = track
    }

    /// Forwards an event to the host, stamping every paywall event with the placement
    /// it fired from.
    private func log(_ name: String, _ parameters: [String: Any] = [:]) {
        track(name, parameters.merging(["source": source]) { _, new in new })
    }

    // MARK: - Intents

    /// `shown`: false for a page built behind another tab, which `markShown`
    /// reports once it is the one on screen.
    func loadOfferings(shown: Bool = true) async {
        if offerings == nil {
            isLoading = true
            defer { isLoading = false }
            do {
                let offerings = try await service.fetchOfferings()
                withAnimation(.easeInOut(duration: 0.25)) { apply(offerings) }
                loadFailed = false
            } catch {
                loadFailed = true
                log("paywall_offerings_failed", ["message": "\(error)"])
                return
            }
        }
        if shown || reportShownWhenLoaded {
            reportShownWhenLoaded = false
            await reportShown()
        }
    }

    /// A page built hidden is now the tab on screen: one `paywall_shown`, at
    /// once if its plans are known, else when they land.
    func markShown() async {
        guard !markedShown else { return }
        markedShown = true
        if offerings == nil {
            reportShownWhenLoaded = true
        } else {
            await reportShown()
        }
    }

    private var markedShown = false
    private var reportShownWhenLoaded = false

    private func reportShown() async {
        log("paywall_shown", ["has_trial": selectedHasTrial, "has_intro_offer": selectedIntroOffer != nil])
        await service.logPaywallShown()
    }

    private func apply(_ offerings: PaywallOfferings) {
        self.offerings = offerings
        if selectedPlanID == nil {
            selectedPlanID = offerings.plans.first { $0.period == preferredPeriod }?.id
                ?? offerings.defaultPlan(featuring: featuredPeriod)?.id
        }
    }

    /// Follows a choice made on another tab: selects this tab's plan of that
    /// cadence, if it has one. Not the user's choice here, so nothing is logged.
    func follow(period: PaywallPlan.Period) {
        preferredPeriod = period
        guard let plan = plans.first(where: { $0.period == period }) else { return }
        selectedPlanID = plan.id
    }

    func selectPlan(_ plan: PaywallPlan) {
        guard plan.id != selectedPlanID else { return }
        selectedPlanID = plan.id
        log("paywall_plan_selected", ["plan": plan.analyticsName])
    }

    func purchase() async -> Bool {
        guard let plan = selectedPlan else { return false }
        log("paywall_continue_button_tapped", ["plan": plan.analyticsName])

        isPurchasing = true
        defer { isPurchasing = false }

        switch await service.purchase(plan: plan) {
        case .purchased:
            log("subscription_started", ["plan": plan.analyticsName])
            return true
        case .cancelled:
            log("subscription_purchase_cancelled", ["plan": plan.analyticsName])
            return false
        case .pending:
            log("subscription_purchase_pending", ["plan": plan.analyticsName])
            isPendingApproval = true
            showPendingApprovalAlert = true
            return false
        case .notEntitled:
            log("subscription_purchase_failed", ["plan": plan.analyticsName, "message": "not_entitled"])
            purchaseError = String(localized: "Something went wrong. Please try again.", bundle: .module)
            return false
        case let .failed(diagnostic):
            log("subscription_purchase_failed", ["plan": plan.analyticsName, "message": diagnostic])
            purchaseError = String(
                localized: "The purchase didn't complete. If your payment went through, the app will unlock automatically in a moment.",
                bundle: .module
            )
            return false
        }
    }

    /// The corner close button on a dismissible paywall.
    func userDismissed() {
        log("paywall_close_button_tapped")
    }

    /// The named decline on a dismissible paywall — tracked separately from the
    /// corner dismiss, because "chose the free path" and "bailed out" say very
    /// different things about whether the pitch landed.
    func userDeclined() {
        log("paywall_declined")
    }

    func restorePurchases() async -> Bool {
        log("restore_button_tapped")
        switch await service.restorePurchases() {
        case .restored:
            log("restore_purchase_succeeded")
            return true
        case .notEntitled, .failed:
            log("restore_purchase_failed")
            showRestoreFailedAlert = true
            return false
        }
    }

    func redeemCodeTapped() {
        log("offer_code_button_tapped")
    }

    /// The sheet reports only that it closed, not whether a code went through, so
    /// the entitlement is read back. A closed sheet with no entitlement stays
    /// quiet: it is as likely a change of mind as a code still on its way, and a
    /// late one unlocks through the host's out-of-band path.
    func codeRedemptionFinished(_ result: Result<Void, any Error>) async -> Bool {
        if case let .failure(error) = result {
            if case StoreKitError.userCancelled = error {
                log("offer_code_sheet_cancelled")
            } else {
                log("offer_code_redemption_failed", ["message": "\(error)"])
            }
            return false
        }
        let entitled = await service.syncEntitlement()
        log("offer_code_sheet_closed", ["entitled": entitled])
        return entitled
    }
}
