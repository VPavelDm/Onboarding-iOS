//
//  OfferClockTests.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation
import Testing
@testable import Paywalls

@MainActor
struct OfferClockTests {

    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private let ordinary: Duration = .seconds(45 * 60)

    private func event(_ id: String = "halloween", minutes: Int = 45, liveNow: Bool = true) -> OfferEvent {
        OfferEvent(
            id: id,
            startsAt: now.addingTimeInterval(liveNow ? -3600 : 3600),
            endsAt: now.addingTimeInterval(liveNow ? 3600 : 7200),
            durationMinutes: minutes,
            image: "OfferHalloween",
            theme: "halloween"
        )
    }

    private func freshDefaults() -> UserDefaults {
        let name = "OfferClockTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func clock(_ defaults: UserDefaults, at now: Date? = nil, keyPrefix: String = "offer_") -> OfferClock {
        let now = now ?? self.now
        return OfferClock(ordinaryDuration: ordinary, defaults: defaults, keyPrefix: keyPrefix, now: { now })
    }

    @Test func eventToOffer_picksTheFirstLiveEventNotYetHad() {
        let clock = clock(freshDefaults())
        let later = event("black_friday", liveNow: false)
        let live = event("halloween")

        #expect(clock.eventToOffer(from: [later, live]) == live)
    }

    @Test func start_withEvent_marksItUsedAndRunsForItsDuration() {
        let defaults = freshDefaults()
        let clock = clock(defaults)

        clock.start(event: event(minutes: 30))

        #expect(clock.remaining() == .seconds(30 * 60))
        #expect(clock.usedEventIDs == ["halloween"])
        // The running window's event comes back, as started (30 minutes), not the list's.
        #expect(clock.eventToOffer(from: [event()])?.durationMinutes == 30)
        #expect(self.clock(defaults, at: now.addingTimeInterval(31 * 60)).eventToOffer(from: [event()]) == nil)
    }

    @Test func init_restoresARunningEventWindow() {
        let defaults = freshDefaults()
        clock(defaults).start(event: event(minutes: 45))

        let later = now.addingTimeInterval(600)
        let relaunched = clock(defaults, at: later)

        #expect(relaunched.event?.id == "halloween")
        #expect(relaunched.remaining(at: later) == .seconds(35 * 60))
        #expect(relaunched.isActive())
    }

    @Test func init_dropsAnExpiredEventWindow() {
        let defaults = freshDefaults()
        clock(defaults).start(event: event(minutes: 45))

        let relaunched = clock(defaults, at: now.addingTimeInterval(46 * 60))

        #expect(relaunched.hasStarted == false)
        #expect(relaunched.usedEventIDs == ["halloween"])
    }

    @Test func start_ordinaryOffer_isNotRemembered() {
        let defaults = freshDefaults()
        let clock = clock(defaults)
        clock.start()

        #expect(clock.remaining() == ordinary)
        #expect(self.clock(defaults).hasStarted == false)
    }

    @Test func start_twice_keepsTheFirstWindow() {
        let clock = clock(freshDefaults())
        clock.start(event: event(minutes: 10))
        clock.start(event: event("second", minutes: 60))

        #expect(clock.event?.id == "halloween")
        #expect(clock.usedEventIDs == ["halloween"])
    }

    @Test func keys_takeTheHostsPrefix() {
        let defaults = freshDefaults()
        clock(defaults, keyPrefix: "promo_").start(event: event())

        #expect(defaults.stringArray(forKey: "promo_events_used") == ["halloween"])
        #expect(defaults.data(forKey: "promo_event_active") != nil)
        #expect(defaults.object(forKey: "offer_events_used") == nil)
    }

    @Test func labels_countDownAndFillTheTemplate() {
        let clock = clock(freshDefaults())
        clock.start(event: event(minutes: 10))
        let later = now.addingTimeInterval(2)

        #expect(clock.remainingLabel(at: later) == "9:58")
        #expect(clock.endsInLabel(at: later, template: "Ends in {time}") == "Ends in 9:58")
        #expect(clock.isExpired(at: now.addingTimeInterval(600)))
        #expect(clock.remaining(at: now.addingTimeInterval(601)) == .zero)
    }
}
