//
//  PaywallTabSplitTests.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation
import Testing
@testable import Paywalls

struct PaywallTabSplitTests {

    /// A host's rule on ids: level 1 sells "songs", every other level "lyrics".
    private let levels = ["lyrics_weekly": 2, "songs_weekly": 1, "lyrics_monthly": 2, "songs_yearly": 1, "legacy": 3]

    private func tab(_ id: String) -> String? {
        levels[id].map { $0 == 1 ? "songs" : "lyrics" }
    }

    @Test func split_putsEachItemOnItsTab_inThePlacementsOrder() throws {
        let ids = ["lyrics_weekly", "songs_weekly", "lyrics_monthly", "songs_yearly", "legacy"]
        let split = try #require(PaywallTabSplit.split(ids, tab: tab))

        #expect(split["songs"] == ["songs_weekly", "songs_yearly"])
        #expect(split["lyrics"] == ["lyrics_weekly", "lyrics_monthly", "legacy"])
    }

    @Test func split_leavesAOneTabPlacementWhole() {
        #expect(PaywallTabSplit.split(["songs_weekly", "songs_yearly"], tab: tab) == nil)
        #expect(PaywallTabSplit.split(["lyrics_weekly", "legacy"], tab: tab) == nil)
        #expect(PaywallTabSplit.split([String](), tab: tab) == nil)
    }

    @Test func split_showsNoTabs_whenAnItemIsPlacedNowhere() {
        #expect(PaywallTabSplit.split(["songs_weekly", "unknown"], tab: tab) == nil)
        #expect(PaywallTabSplit.split(["songs_weekly", "lyrics_weekly", "unknown"], tab: tab) == nil)
    }

    @Test func soleTab_isTheTabEveryItemShares() {
        #expect(PaywallTabSplit.soleTab(["lyrics_weekly", "legacy"], tab: tab, fallback: "songs") == "lyrics")
        #expect(PaywallTabSplit.soleTab(["songs_weekly"], tab: tab, fallback: "songs") == "songs")
    }

    @Test func soleTab_fallsBack_whenAnItemIsPlacedNowhere_orThereAreNone() {
        #expect(PaywallTabSplit.soleTab(["lyrics_weekly", "unknown"], tab: tab, fallback: "songs") == "songs")
        #expect(PaywallTabSplit.soleTab(["unknown"], tab: tab, fallback: "songs") == "songs")
        #expect(PaywallTabSplit.soleTab([String](), tab: tab, fallback: "songs") == "songs")
    }

    @Test func byGroupLevel_placesAPlanByItsLevel_andNoneWithoutOne() {
        let rule = PaywallTabRule.byGroupLevel { $0 == 1 ? "pro" : "basic" }
        let plan = PaywallPlan(id: "p", period: .weekly, price: 1, localizedPrice: "$1", freeTrialDays: nil)

        #expect(rule.tab(plan, 1) == "pro")
        #expect(rule.tab(plan, 7) == "basic")
        #expect(rule.tab(plan, nil) == nil)
    }
}
