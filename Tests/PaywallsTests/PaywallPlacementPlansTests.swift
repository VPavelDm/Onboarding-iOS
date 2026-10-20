//
//  PaywallPlacementPlansTests.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation
import Testing
@testable import Paywalls

@MainActor
struct PaywallPlacementPlansTests {

    private let songsWeekly = PaywallPlan(id: "songs_weekly", period: .weekly, price: 5.99, localizedPrice: "$5.99", freeTrialDays: nil)
    private let songsYearly = PaywallPlan(id: "songs_yearly", period: .yearly, price: 59.99, localizedPrice: "$59.99", freeTrialDays: nil)
    private let lyricsMonthly = PaywallPlan(id: "lyrics_monthly", period: .monthly, price: 8.99, localizedPrice: "$8.99", freeTrialDays: 3)

    private let rule = PaywallTabRule.byGroupLevel { $0 == 1 ? "songs" : "lyrics" }

    /// Counts the level reads, so a shared fetch can be told from two.
    @MainActor
    private final class Levels {
        var byID: [String: Int]
        private(set) var reads = 0
        init(_ byID: [String: Int]) { self.byID = byID }
        func levels(_ ids: [String]) async -> [String: Int] {
            reads += 1
            return byID.filter { ids.contains($0.key) }
        }
    }

    private func placement(_ service: FakePaywallService, levels: Levels) -> PaywallPlacementPlans {
        PaywallPlacementPlans(service: service, tabIDs: ["songs", "lyrics"], rule: rule, groupLevels: levels.levels)
    }

    @Test func plans_splitThePlacementByTab_fromOneFetch() async throws {
        let service = FakePaywallService(plans: [lyricsMonthly, songsWeekly, songsYearly])
        let levels = Levels(["songs_weekly": 1, "songs_yearly": 1, "lyrics_monthly": 2])
        let placement = placement(service, levels: levels)

        let songs = try await placement.plans(for: "songs")
        let lyrics = try await placement.plans(for: "lyrics")

        #expect(songs.plans.map(\.id) == ["songs_weekly", "songs_yearly"])
        #expect(lyrics.plans.map(\.id) == ["lyrics_monthly"])
        #expect(service.fetchCount == 1)
        #expect(levels.reads == 1)
    }

    @Test func plans_serveAOneKindPlacementOnItsTab_andNothingOnTheOther() async throws {
        let service = FakePaywallService(plans: [lyricsMonthly])
        let placement = placement(service, levels: Levels(["lyrics_monthly": 2]))

        let lyrics = try await placement.plans(for: "lyrics")
        #expect(lyrics.plans.map(\.id) == ["lyrics_monthly"])

        await #expect(throws: PaywallPlacementPlansError.noPlans(tabID: "songs")) {
            try await placement.plans(for: "songs")
        }
    }

    @Test func plans_fallBackToTheFirstTab_whenALevelIsUnknown() async throws {
        let service = FakePaywallService(plans: [songsWeekly, lyricsMonthly])
        let placement = placement(service, levels: Levels(["songs_weekly": 1]))

        let songs = try await placement.plans(for: "songs")
        #expect(songs.plans.map(\.id) == ["songs_weekly", "lyrics_monthly"])

        await #expect(throws: PaywallPlacementPlansError.noPlans(tabID: "lyrics")) {
            try await placement.plans(for: "lyrics")
        }
    }

    @Test func plans_forgetAFailedFetch_soTheNextAskTriesAgain() async throws {
        let service = FakePaywallService(plans: [songsWeekly], fetchFails: true)
        let placement = placement(service, levels: Levels(["songs_weekly": 1]))

        await #expect(throws: URLError.self) {
            try await placement.plans(for: "songs")
        }
        service.fetchFails = false

        let songs = try await placement.plans(for: "songs")
        #expect(songs.plans.map(\.id) == ["songs_weekly"])
        #expect(service.fetchCount == 2)
    }

    @Test func tabService_fetchesItsTab_andCountsAViewOnlyWhenAsked() async throws {
        let service = FakePaywallService(plans: [songsWeekly, lyricsMonthly])
        let placement = placement(service, levels: Levels(["songs_weekly": 1, "lyrics_monthly": 2]))

        let silent = placement.service(for: "lyrics", logsView: false)
        let loud = placement.service(for: "songs", logsView: true)

        #expect(try await silent.fetchOfferings().plans.map(\.id) == ["lyrics_monthly"])
        await silent.logPaywallShown()
        #expect(service.shownCount == 0)
        await loud.logPaywallShown()
        #expect(service.shownCount == 1)
        await placement.logShown()
        #expect(service.shownCount == 2)

        service.purchaseOutcome = .purchased
        _ = await silent.purchase(plan: lyricsMonthly)
        #expect(service.purchasedPlanIDs == ["lyrics_monthly"])
    }
}
