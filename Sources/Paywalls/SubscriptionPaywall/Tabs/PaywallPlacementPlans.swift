//
//  PaywallPlacementPlans.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation
import StoreKit

/// One placement's plans, fetched once and served by tab (`PaywallTabRule`,
/// `PaywallTabSplit`): a tabbed paywall's tabs share one placement, and
/// each tab's `PaywallViewModel` gets a service of its own (`service(for:logsView:)`)
/// that fetches from here. Purchases and restores go through the placement's
/// own service, which knows every product it fetched. The store's view count
/// (`logShown`) is the tabs' to report once, whichever tabs are looked at.
@MainActor
public final class PaywallPlacementPlans {

    /// The tabs the placement is served on, in order. The first is the
    /// fallback: the tab an unsplit placement sells for when its plans'
    /// kind cannot be told (`PaywallTabSplit.soleTab`).
    public let tabIDs: [String]

    private let base: PaywallServiceProtocol
    private let rule: PaywallTabRule
    /// Product id → its level in its App Store subscription group.
    private let groupLevels: @MainActor ([String]) async -> [String: Int]
    private var fetch: Task<(plans: [PaywallPlan], levels: [String: Int]), Error>?

    /// `groupLevels` reads the products' levels; the default asks StoreKit.
    public init(
        service: PaywallServiceProtocol,
        tabIDs: [String],
        rule: PaywallTabRule,
        groupLevels: @escaping @MainActor ([String]) async -> [String: Int] = PaywallPlacementPlans.storeKitGroupLevels
    ) {
        precondition(!tabIDs.isEmpty, "a placement needs at least one tab")
        self.base = service
        self.tabIDs = tabIDs
        self.rule = rule
        self.groupLevels = groupLevels
    }

    /// The plans sold on `tabID`. Throws `PaywallPlacementPlansError.noPlans`
    /// when the placement sells nothing for it. A failed fetch is forgotten,
    /// so the next ask tries again.
    public func plans(for tabID: String) async throws -> PaywallOfferings {
        let task = fetch ?? Task {
            let plans = try await base.fetchOfferings().plans
            return (plans, await groupLevels(plans.map(\.id)))
        }
        fetch = task
        let all: (plans: [PaywallPlan], levels: [String: Int])
        do {
            all = try await task.value
        } catch {
            fetch = nil
            throw error
        }
        let tab: (PaywallPlan) -> String? = { [rule] plan in rule.tab(plan, all.levels[plan.id]) }
        let plans: [PaywallPlan] = if let split = PaywallTabSplit.split(all.plans, tab: tab) {
            split[tabID] ?? []
        } else {
            PaywallTabSplit.soleTab(all.plans, tab: tab, fallback: tabIDs[0]) == tabID ? all.plans : []
        }
        guard !plans.isEmpty else { throw PaywallPlacementPlansError.noPlans(tabID: tabID) }
        return PaywallOfferings(plans: plans)
    }

    /// A `PaywallServiceProtocol` for one tab, to build its `PaywallViewModel`
    /// on. `logsView`: whether showing this tab counts as a view of the
    /// placement in the store; a tabbed paywall passes false and reports the
    /// one view itself (`logShown`), a single paywall on one tab passes true.
    public func service(for tabID: String, logsView: Bool) -> PaywallServiceProtocol {
        PaywallTabService(plans: self, tabID: tabID, logsView: logsView)
    }

    /// Reports one view of the placement to the store.
    public func logShown() async {
        await base.logPaywallShown()
    }

    /// The levels App Store Connect gives the products, from StoreKit. A
    /// product that isn't a subscription, or a failed load, leaves its level
    /// unknown, which shows the paywall without tabs.
    public static func storeKitGroupLevels(_ ids: [String]) async -> [String: Int] {
        guard let products = try? await Product.products(for: ids) else { return [:] }
        return Dictionary(
            products.compactMap { product in product.subscription.map { (product.id, $0.groupLevel) } },
            uniquingKeysWith: { first, _ in first }
        )
    }

    fileprivate func purchase(plan: PaywallPlan) async -> PaywallPurchaseOutcome {
        await base.purchase(plan: plan)
    }

    fileprivate func restorePurchases() async -> PaywallRestoreOutcome {
        await base.restorePurchases()
    }

    fileprivate func syncEntitlement() async -> Bool {
        await base.syncEntitlement()
    }
}

public enum PaywallPlacementPlansError: Error, Equatable {
    /// The placement sells nothing for this tab.
    case noPlans(tabID: String)
}

/// The package paywall's service for one tab of a shared placement.
private struct PaywallTabService: PaywallServiceProtocol {
    let plans: PaywallPlacementPlans
    let tabID: String
    let logsView: Bool

    func fetchOfferings() async throws -> PaywallOfferings {
        try await plans.plans(for: tabID)
    }

    func purchase(plan: PaywallPlan) async -> PaywallPurchaseOutcome {
        await plans.purchase(plan: plan)
    }

    func restorePurchases() async -> PaywallRestoreOutcome {
        await plans.restorePurchases()
    }

    func logPaywallShown() async {
        guard logsView else { return }
        await plans.logShown()
    }

    func syncEntitlement() async -> Bool {
        await plans.syncEntitlement()
    }
}
