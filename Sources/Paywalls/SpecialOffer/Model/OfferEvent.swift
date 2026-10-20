//
//  OfferEvent.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation

/// A special offer with dates: a Halloween special, Black Friday, the
/// holidays. The host keeps the list wherever it likes (a remote config
/// key, say) so a season starts and ends without a release, and hands the
/// decoded `[OfferEvent]` to `OfferClock.eventToOffer(from:)`, which offers
/// each user a given event once. `image` and `theme` are the host's own
/// words: it reads them back into its artwork and wording when it builds
/// the `OfferConfiguration`. `placementID` is the placement the event sells;
/// nil means the host's ordinary offer placement.
///
/// ```json
/// [{ "id": "halloween_2026", "startsAt": "2026-10-27T00:00:00Z",
///    "endsAt": "2026-11-03T00:00:00Z", "durationMinutes": 45,
///    "image": "OfferHalloween", "theme": "halloween",
///    "placementID": "discounted_onboarding" }]
/// ```
public struct OfferEvent: Codable, Equatable, Sendable, Identifiable {
    public var id: String
    public var startsAt: Date
    public var endsAt: Date
    /// How long the price stands once the user has seen it.
    public var durationMinutes: Int
    public var image: String?
    public var theme: String?
    public var placementID: String?

    public init(
        id: String,
        startsAt: Date,
        endsAt: Date,
        durationMinutes: Int,
        image: String? = nil,
        theme: String? = nil,
        placementID: String? = nil
    ) {
        self.id = id
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.durationMinutes = durationMinutes
        self.image = image
        self.theme = theme
        self.placementID = placementID
    }

    /// The offer's window once seen; a minute at least.
    public var duration: Duration { .seconds(max(durationMinutes, 1) * 60) }

    public func isLive(at now: Date) -> Bool {
        startsAt <= now && now < endsAt
    }

    /// The first event live at `now` that isn't among `used`.
    public static func next(from events: [OfferEvent], excluding used: Set<String>, at now: Date) -> OfferEvent? {
        events.first { $0.isLive(at: now) && !used.contains($0.id) }
    }

    /// Decodes `[OfferEvent]` with dates as ISO 8601, with or without
    /// fractional seconds ("2026-10-27T00:00:00Z", "...00.000Z").
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let string = try decoder.singleValueContainer().decode(String.self)
            let plain = ISO8601DateFormatter()
            let fractional = ISO8601DateFormatter()
            fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            guard let date = plain.date(from: string) ?? fractional.date(from: string) else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Not an ISO 8601 date: \(string)"))
            }
            return date
        }
        return decoder
    }

    public static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
