//
//  PaywallTabsViewModel.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation

/// A paywall with tabs under its headline: one `PaywallViewModel` per tab,
/// the picker choosing which is on screen. Each tab keeps its own plans and
/// selection, so going back to a tab finds it as it was left. Decides which
/// tab opens first, reports the paywall as shown once for all its tabs, and
/// stamps every tab's events with the tab they came from.
///
/// Analytics: every event a tab's `PaywallViewModel` sends carries the tab's
/// id under `tabParameter` ("tab" unless the host names it otherwise) next to
/// the `source` the package already stamps; a switch sends
/// `paywall_tab_selected` with the same two.
@MainActor
@Observable
public final class PaywallTabsViewModel {

    /// One tab and the paywall it shows.
    public struct Page {
        public let tab: PaywallTab
        public let paywall: PaywallViewModel
    }

    public let pages: [Page]
    public private(set) var selectedIndex: Int
    /// The close appears this long after the paywall opens, whichever tab is up.
    public let closeButtonDelay: Duration
    /// Flip once, on the first unlock or close, so the exits stay single-shot
    /// (a restore and a purchase cannot both fire) and a view can tap its
    /// success haptic on `unlocked`.
    public private(set) var unlocked = false
    public private(set) var dismissed = false

    /// The placement the tab events are stamped with.
    private let source: String
    private let tabParameter: String
    private let logShown: @MainActor () async -> Void
    private var didLogShown = false
    private let track: @MainActor (String, [String: Any]) -> Void

    /// `service` makes each tab's `PaywallServiceProtocol`; it must not count
    /// a view of its own, as `logShown` reports the one view of the whole
    /// paywall. `initialTabID` names the tab that opens first (the first tab
    /// when it names none).
    public init(
        tabs: [PaywallTab],
        initialTabID: String,
        source: String,
        closeButtonDelay: Duration = .zero,
        tabParameter: String = "tab",
        service: (PaywallTab) -> PaywallServiceProtocol,
        logShown: @escaping @MainActor () async -> Void,
        track: @escaping @MainActor (String, [String: Any]) -> Void = { _, _ in }
    ) {
        precondition(!tabs.isEmpty, "a tabbed paywall needs at least one tab")
        self.source = source
        self.tabParameter = tabParameter
        self.closeButtonDelay = closeButtonDelay
        self.logShown = logShown
        self.track = track
        self.pages = tabs.map { tab in
            Page(
                tab: tab,
                paywall: PaywallViewModel(service: service(tab), source: source) { name, parameters in
                    track(name, parameters.merging([tabParameter: tab.id]) { _, new in new })
                }
            )
        }
        self.selectedIndex = tabs.firstIndex { $0.id == initialTabID } ?? 0
    }

    /// The tabs over one placement (`PaywallPlacementPlans`): each tab's
    /// service serves the placement's plans for it, and the placement's view
    /// is reported once.
    public convenience init(
        tabs: [PaywallTab],
        placement: PaywallPlacementPlans,
        initialTabID: String,
        source: String,
        closeButtonDelay: Duration = .zero,
        tabParameter: String = "tab",
        track: @escaping @MainActor (String, [String: Any]) -> Void = { _, _ in }
    ) {
        self.init(
            tabs: tabs,
            initialTabID: initialTabID,
            source: source,
            closeButtonDelay: closeButtonDelay,
            tabParameter: tabParameter,
            service: { placement.service(for: $0.id, logsView: false) },
            logShown: { await placement.logShown() },
            track: track
        )
    }

    public var tabs: [PaywallTab] { pages.map(\.tab) }

    public var titles: [String] { pages.map(\.tab.title) }

    public var current: Page { pages[selectedIndex] }

    public var selectedTab: PaywallTab { current.tab }

    /// One view of the placement per opening, whichever tabs are seen.
    public func onAppear() async {
        guard !didLogShown else { return }
        didLogShown = true
        await logShown()
    }

    public func select(index: Int) {
        guard pages.indices.contains(index), index != selectedIndex else { return }
        selectedIndex = index
        track("paywall_tab_selected", [tabParameter: pages[index].tab.id, "source": source])
    }

    public func select(tabID: String) {
        guard let index = pages.firstIndex(where: { $0.tab.id == tabID }) else { return }
        select(index: index)
    }

    /// True the first time only.
    public func markUnlocked() -> Bool {
        guard !unlocked, !dismissed else { return false }
        unlocked = true
        return true
    }

    public func markDismissed() -> Bool {
        guard !unlocked, !dismissed else { return false }
        dismissed = true
        return true
    }
}
