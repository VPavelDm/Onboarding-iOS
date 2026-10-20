//
//  OfferViewModel.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import SwiftUI
import Observation

/// The special offer: one discounted plan on a clock. Loads the plan from
/// the offer's placement, starts the shared `OfferClock` the first time it
/// appears (the host keeps showing the same clock afterwards), and turns
/// purchase / restore / close / expiry into two exits. Store work goes
/// through the host's `PaywallServiceProtocol`, so the store and the
/// entitlement refresh behave exactly as on the main paywall; the events are
/// the ones `PaywallViewModel` sends, stamped with `source` (the placement)
/// and, for an event, `event` (its id), so the two placements read alike.
@Observable
@MainActor
public final class OfferViewModel {

    public enum Phase: Equatable {
        case loading
        case ready
        case purchasing
    }

    public let configuration: OfferConfiguration
    public let placementID: String
    public let clock: OfferClock
    /// The event this offer is for; nil for the ordinary offer.
    public let event: OfferEvent?

    public private(set) var phase: Phase = .loading
    public private(set) var plan: PaywallPlan?
    public var alert: OfferAlert?

    private let service: PaywallServiceProtocol
    private let track: @MainActor (String, [String: Any]) -> Void
    private var finished = false

    public init(
        configuration: OfferConfiguration,
        placementID: String,
        service: PaywallServiceProtocol,
        clock: OfferClock,
        event: OfferEvent? = nil,
        track: @escaping @MainActor (String, [String: Any]) -> Void = { _, _ in }
    ) {
        self.configuration = configuration
        self.placementID = placementID
        self.service = service
        self.clock = clock
        self.event = event
        self.track = track
    }

    // MARK: - Derived

    public var priceLabel: String? { plan?.localizedPrice }

    /// "50" in "50% OFF".
    public var percentOff: Int? { plan.map(OfferPitch.percentOff) }

    /// "$59.99", struck through before the price.
    public var regularPriceLabel: String? { plan.map { OfferPitch.format(OfferPitch.regularPrice(of: $0), like: $0) } }

    /// "$0.09" in "(less than $0.09 per day)".
    public var perDayLabel: String? {
        guard let plan, let perDay = OfferPitch.pricePerDayCeiling(plan) else { return nil }
        return OfferPitch.format(perDay, like: plan)
    }

    /// "Just {old} {new} per year", for the plan's cadence.
    public var priceLineTemplate: String? {
        plan.flatMap { configuration.priceLineTemplates[$0.period] }
    }

    public var ctaTitle: String { configuration.ctaTitle }

    /// "Spooky deal ends in 42:43".
    public func endsInLabel(at now: Date) -> String {
        clock.endsInLabel(at: now, template: configuration.endsInTemplate)
    }

    public var canPurchase: Bool { phase == .ready && plan != nil }

    public func remaining(at now: Date) -> Duration { clock.remaining(at: now) }

    public func remainingLabel(at now: Date) -> String { clock.remainingLabel(at: now) }

    public func isExpired(at now: Date) -> Bool { clock.isExpired(at: now) }

    // MARK: - Lifecycle

    /// Starts the clock and fetches the plan. A placement that yields nothing
    /// ends the step at once: an offer with no price is not worth a screen.
    public func onAppear() async -> Bool {
        clock.start(event: event)
        guard plan == nil else { return true }
        do {
            let offerings = try await service.fetchOfferings()
            guard let first = offerings.plans.first else {
                log("paywall_offerings_failed", ["message": "no_plans"])
                return false
            }
            plan = first
            phase = .ready
            log("paywall_shown", ["has_trial": first.hasFreeTrial, "countdown_seconds": Int(clock.remaining().components.seconds)])
            return true
        } catch {
            log("paywall_offerings_failed", ["message": "\(error)"])
            return false
        }
    }

    // MARK: - Intents

    /// Buys the one plan. `true` when it went through.
    public func purchase() async -> Bool {
        guard let plan, canPurchase else { return false }
        let name = plan.analyticsName
        log("paywall_continue_button_tapped", ["plan": name])
        phase = .purchasing
        defer { if phase == .purchasing { phase = .ready } }
        switch await service.purchase(plan: plan) {
        case .purchased:
            log("subscription_started", ["plan": name, "product_id": plan.id])
            return finish()
        case .cancelled:
            log("subscription_purchase_cancelled", ["plan": name])
        case .pending:
            log("subscription_purchase_pending", ["plan": name])
        case .notEntitled:
            log("subscription_purchase_failed", ["plan": name, "message": "not_entitled"])
            alert = .purchaseFailed
        case .failed(let diagnostic):
            log("subscription_purchase_failed", ["plan": name, "message": diagnostic])
            alert = .purchaseFailed
        }
        return false
    }

    public func restore() async -> Bool {
        guard phase != .purchasing else { return false }
        log("restore_button_tapped")
        phase = .purchasing
        defer { if phase == .purchasing { phase = .ready } }
        switch await service.restorePurchases() {
        case .restored:
            log("restore_purchase_succeeded")
            return finish()
        case .notEntitled, .failed:
            log("restore_purchase_failed")
            alert = .restoreFailed
            return false
        }
    }

    /// The corner close. `true` the first time only.
    public func decline() -> Bool {
        guard phase != .purchasing else { return false }
        log("paywall_declined")
        return finish()
    }

    /// The clock ran out. Nothing happens while a payment sheet is up; the
    /// next tick after it closes ends the step instead.
    public func expire() -> Bool {
        guard phase != .purchasing else { return false }
        log("paywall_offer_expired")
        return finish()
    }

    private func finish() -> Bool {
        guard !finished else { return false }
        finished = true
        return true
    }

    private func log(_ name: String, _ parameters: [String: Any] = [:]) {
        var stamped: [String: Any] = ["source": placementID]
        if let event { stamped["event"] = event.id }
        track(name, parameters.merging(stamped) { _, new in new })
    }

    /// The alert's message: the host's, else the package's.
    func message(for alert: OfferAlert) -> String {
        switch alert {
        case .purchaseFailed:
            configuration.purchaseFailedMessage ?? String(localized: "Something went wrong. Please try again.", bundle: .module)
        case .restoreFailed:
            configuration.restoreFailedMessage ?? String(localized: "We couldn't find an active subscription on this account.", bundle: .module)
        }
    }
}

public enum OfferAlert: Identifiable, Sendable {
    case purchaseFailed
    case restoreFailed

    public var id: Self { self }
}
