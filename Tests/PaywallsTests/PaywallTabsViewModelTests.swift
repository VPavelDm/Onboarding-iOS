//
//  PaywallTabsViewModelTests.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation
import Testing
@testable import Paywalls

@MainActor
struct PaywallTabsViewModelTests {

    private let weekly = PaywallPlan(id: "weekly", period: .weekly, price: 4.99, localizedPrice: "$4.99", freeTrialDays: nil)
    private let monthly = PaywallPlan(id: "monthly", period: .monthly, price: 8.99, localizedPrice: "$8.99", freeTrialDays: 3)

    private func configuration() -> PaywallConfiguration {
        PaywallConfiguration(features: [], trialUnlockBody: "")
    }

    private var tabs: [PaywallTab] {
        [
            PaywallTab(id: "songs", title: "Songs", configuration: configuration()),
            PaywallTab(id: "lyrics", title: "Lyrics", configuration: configuration())
        ]
    }

    /// Records every event the host would get.
    @MainActor
    private final class Recorder {
        var events: [(name: String, parameters: [String: Any])] = []
        var shown = 0
        func track(_ name: String, _ parameters: [String: Any]) { events.append((name, parameters)) }
        func logShown() async { shown += 1 }
    }

    private func viewModel(_ recorder: Recorder, services: [String: FakePaywallService], initial: String = "songs", tabParameter: String = "tab") -> PaywallTabsViewModel {
        PaywallTabsViewModel(
            tabs: tabs,
            initialTabID: initial,
            source: "onboarding",
            closeButtonDelay: .seconds(3),
            tabParameter: tabParameter,
            service: { services[$0.id]! },
            logShown: { await recorder.logShown() },
            track: { recorder.track($0, $1) }
        )
    }

    private var services: [String: FakePaywallService] {
        ["songs": FakePaywallService(plans: [weekly]), "lyrics": FakePaywallService(plans: [monthly])]
    }

    @Test func opensOnTheNamedTab_orTheFirst() {
        let recorder = Recorder()
        #expect(viewModel(recorder, services: services, initial: "lyrics").selectedIndex == 1)
        #expect(viewModel(recorder, services: services, initial: "lyrics").selectedTab.id == "lyrics")
        #expect(viewModel(recorder, services: services, initial: "nowhere").selectedIndex == 0)
        #expect(viewModel(recorder, services: services).titles == ["Songs", "Lyrics"])
        #expect(viewModel(recorder, services: services).closeButtonDelay == .seconds(3))
    }

    @Test func onAppear_reportsTheViewOnce_whateverTabsAreSeen() async {
        let recorder = Recorder()
        let viewModel = viewModel(recorder, services: services)

        await viewModel.onAppear()
        viewModel.select(index: 1)
        await viewModel.onAppear()

        #expect(recorder.shown == 1)
    }

    @Test func select_switchesTheTab_andTracksItWithTheTabAndSource() {
        let recorder = Recorder()
        let viewModel = viewModel(recorder, services: services)

        viewModel.select(index: 1)
        viewModel.select(index: 1)
        viewModel.select(index: 9)
        viewModel.select(tabID: "songs")

        #expect(viewModel.selectedIndex == 0)
        #expect(recorder.events.map(\.name) == ["paywall_tab_selected", "paywall_tab_selected"])
        #expect(recorder.events[0].parameters["tab"] as? String == "lyrics")
        #expect(recorder.events[0].parameters["source"] as? String == "onboarding")
        #expect(recorder.events[1].parameters["tab"] as? String == "songs")
    }

    @Test func eachTabsEvents_carryItsID_underTheHostsParameterName() async {
        let recorder = Recorder()
        let services = services
        let viewModel = viewModel(recorder, services: services, tabParameter: "paywall_tab")

        await viewModel.pages[1].paywall.loadOfferings()
        services["lyrics"]?.purchaseOutcome = .purchased
        _ = await viewModel.pages[1].paywall.purchase()

        let names = recorder.events.map(\.name)
        #expect(names.contains("paywall_shown"))
        #expect(names.contains("subscription_started"))
        for event in recorder.events {
            #expect(event.parameters["paywall_tab"] as? String == "lyrics", "\(event.name)")
            #expect(event.parameters["source"] as? String == "onboarding", "\(event.name)")
        }
    }

    @Test func tabsOverAPlacement_shareItsFetch_andReportOneView() async throws {
        let recorder = Recorder()
        let service = FakePaywallService(plans: [weekly, monthly])
        let placement = PaywallPlacementPlans(
            service: service,
            tabIDs: ["songs", "lyrics"],
            rule: .byGroupLevel { $0 == 1 ? "songs" : "lyrics" },
            groupLevels: { _ in ["weekly": 1, "monthly": 2] }
        )
        let viewModel = PaywallTabsViewModel(tabs: tabs, placement: placement, initialTabID: "songs", source: "home") { recorder.track($0, $1) }

        await viewModel.pages[0].paywall.loadOfferings()
        await viewModel.pages[1].paywall.loadOfferings(shown: false)
        await viewModel.onAppear()

        #expect(viewModel.pages[0].paywall.plans.map(\.id) == ["weekly"])
        #expect(viewModel.pages[1].paywall.plans.map(\.id) == ["monthly"])
        #expect(service.fetchCount == 1)
        // The tabs' own services never count a view; `onAppear` is the one.
        #expect(service.shownCount == 1)
    }

    @Test func unlockAndDismiss_fireOnce_andNotBoth() {
        let recorder = Recorder()
        let viewModel = viewModel(recorder, services: services)

        #expect(viewModel.markUnlocked())
        #expect(!viewModel.markUnlocked())
        #expect(!viewModel.markDismissed())
        #expect(viewModel.unlocked)

        let other = self.viewModel(recorder, services: services)
        #expect(other.markDismissed())
        #expect(!other.markUnlocked())
    }
}
