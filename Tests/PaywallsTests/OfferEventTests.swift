//
//  OfferEventTests.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation
import Testing
@testable import Paywalls

struct OfferEventTests {

    private func date(_ iso: String) -> Date {
        ISO8601DateFormatter().date(from: iso)!
    }

    @Test func decodes_aRemoteConfigList_withAndWithoutFractionalSeconds() throws {
        let json = """
        [{"id":"halloween_2026","startsAt":"2026-10-27T00:00:00Z","endsAt":"2026-11-03T00:00:00.000Z",
          "durationMinutes":45,"image":"OfferHalloween","theme":"halloween"}]
        """
        let events = try OfferEvent.decoder.decode([OfferEvent].self, from: Data(json.utf8))

        #expect(events.count == 1)
        #expect(events[0].id == "halloween_2026")
        #expect(events[0].image == "OfferHalloween")
        #expect(events[0].theme == "halloween")
        #expect(events[0].placementID == nil)
        #expect(events[0].startsAt == date("2026-10-27T00:00:00Z"))
        #expect(events[0].endsAt == date("2026-11-03T00:00:00Z"))
        #expect(events[0].duration == .seconds(45 * 60))
    }

    @Test func decodes_withTheOptionalFieldsLeftOut() throws {
        let json = """
        [{"id":"plain","startsAt":"2026-10-27T00:00:00Z","endsAt":"2026-11-03T00:00:00Z","durationMinutes":0}]
        """
        let events = try OfferEvent.decoder.decode([OfferEvent].self, from: Data(json.utf8))

        #expect(events[0].image == nil)
        #expect(events[0].theme == nil)
        #expect(events[0].duration == .seconds(60))
    }

    @Test func decoding_rejectsADateThatIsNotISO8601() {
        let json = """
        [{"id":"x","startsAt":"27.10.2026","endsAt":"2026-11-03T00:00:00Z","durationMinutes":45}]
        """
        #expect(throws: DecodingError.self) {
            try OfferEvent.decoder.decode([OfferEvent].self, from: Data(json.utf8))
        }
    }

    @Test func isLive_withinItsDates_endExclusive() throws {
        let event = OfferEvent(
            id: "x", startsAt: date("2026-10-27T00:00:00Z"), endsAt: date("2026-11-03T00:00:00Z"), durationMinutes: 45
        )

        #expect(event.isLive(at: date("2026-10-27T00:00:00Z")))
        #expect(event.isLive(at: date("2026-10-30T12:00:00Z")))
        #expect(!event.isLive(at: date("2026-11-03T00:00:00Z")))
        #expect(!event.isLive(at: date("2026-10-26T23:59:59Z")))
    }

    @Test func next_isTheFirstLiveEventNotYetHad() {
        let now = date("2026-10-30T12:00:00Z")
        let past = OfferEvent(id: "past", startsAt: date("2026-10-01T00:00:00Z"), endsAt: date("2026-10-02T00:00:00Z"), durationMinutes: 45)
        let used = OfferEvent(id: "used", startsAt: date("2026-10-27T00:00:00Z"), endsAt: date("2026-11-03T00:00:00Z"), durationMinutes: 45)
        let live = OfferEvent(id: "live", startsAt: date("2026-10-27T00:00:00Z"), endsAt: date("2026-11-03T00:00:00Z"), durationMinutes: 45)

        #expect(OfferEvent.next(from: [past, used, live], excluding: ["used"], at: now) == live)
        #expect(OfferEvent.next(from: [past], excluding: [], at: now) == nil)
    }

    @Test func roundTrips_throughTheEncoder() throws {
        let event = OfferEvent(
            id: "x", startsAt: date("2026-10-27T00:00:00Z"), endsAt: date("2026-11-03T00:00:00Z"),
            durationMinutes: 45, image: "Art", theme: "t", placementID: "p"
        )
        let data = try OfferEvent.encoder.encode(event)

        #expect(try OfferEvent.decoder.decode(OfferEvent.self, from: data) == event)
    }
}
