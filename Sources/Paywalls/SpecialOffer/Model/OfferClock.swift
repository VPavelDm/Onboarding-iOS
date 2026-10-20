//
//  OfferClock.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation
import Observation

/// The one offer window at a time. The offer screen starts it the first
/// time it appears; the host reads it to show the clock elsewhere (a banner)
/// and to open the same offer again while it runs.
///
/// Two kinds of window. The ordinary offer lives in memory on purpose: a
/// restart, or the clock reaching zero, puts the host back on its regular
/// paywall. An event's window (`OfferEvent`) is kept in `UserDefaults`, so it
/// survives a relaunch and the event is offered to this user once only.
///
/// Keys: `<keyPrefix>events_used` (the ids this user has been offered) and
/// `<keyPrefix>event_active` (the running event window); "offer_" by default.
@MainActor
@Observable
public final class OfferClock {

    /// How long the ordinary offer's price stands.
    public let ordinaryDuration: Duration

    public private(set) var expiresAt: Date?
    /// The event this window is for; nil for the ordinary offer.
    public private(set) var event: OfferEvent?

    private let defaults: UserDefaults
    private let usedEventsKey: String
    private let activeEventKey: String
    private let now: () -> Date

    private struct StoredWindow: Codable {
        var event: OfferEvent
        var expiresAt: Date
    }

    /// `now` is the clock the window is read against when a call names no
    /// date of its own.
    public init(
        ordinaryDuration: Duration,
        defaults: UserDefaults = .standard,
        keyPrefix: String = "offer_",
        now: @escaping () -> Date = Date.init
    ) {
        self.ordinaryDuration = ordinaryDuration
        self.defaults = defaults
        self.usedEventsKey = keyPrefix + "events_used"
        self.activeEventKey = keyPrefix + "event_active"
        self.now = now
        if let data = defaults.data(forKey: activeEventKey),
           let stored = try? OfferEvent.decoder.decode(StoredWindow.self, from: data),
           stored.expiresAt > now() {
            event = stored.event
            expiresAt = stored.expiresAt
        } else {
            defaults.removeObject(forKey: activeEventKey)
        }
    }

    /// How long the price stands in this window.
    public var duration: Duration { event?.duration ?? ordinaryDuration }

    /// Starts the clock unless it is already running or has run out. With an
    /// event, the window is remembered and the event counts as used.
    public func start(event: OfferEvent? = nil, now: Date? = nil) {
        guard expiresAt == nil else { return }
        let now = now ?? self.now()
        self.event = event
        let duration = event?.duration ?? ordinaryDuration
        let expiresAt = now.addingTimeInterval(TimeInterval(duration.components.seconds))
        self.expiresAt = expiresAt
        guard let event else { return }
        var used = usedEventIDs
        used.insert(event.id)
        defaults.set(Array(used).sorted(), forKey: usedEventsKey)
        defaults.set(try? OfferEvent.encoder.encode(StoredWindow(event: event, expiresAt: expiresAt)), forKey: activeEventKey)
    }

    public var hasStarted: Bool { expiresAt != nil }

    /// Events this user has already been offered, in this window or earlier.
    public var usedEventIDs: Set<String> {
        Set(defaults.stringArray(forKey: usedEventsKey) ?? [])
    }

    /// The event to offer now: the running window's, else the first live
    /// event this user hasn't had, else none (the ordinary offer).
    public func eventToOffer(from events: [OfferEvent], at now: Date? = nil) -> OfferEvent? {
        if hasStarted { return event }
        return OfferEvent.next(from: events, excluding: usedEventIDs, at: now ?? self.now())
    }

    public func isActive(at now: Date? = nil) -> Bool {
        expiresAt.map { (now ?? self.now()) < $0 } ?? false
    }

    public func isExpired(at now: Date? = nil) -> Bool {
        expiresAt.map { (now ?? self.now()) >= $0 } ?? false
    }

    /// What is left at `now`, never below zero; the full length before the
    /// clock has started so a screen can lay itself out before starting it.
    public func remaining(at now: Date? = nil) -> Duration {
        guard let expiresAt else { return duration }
        return .seconds(max(0, expiresAt.timeIntervalSince(now ?? self.now())))
    }

    /// "9:58".
    public func remainingLabel(at now: Date? = nil) -> String {
        let total = Int(remaining(at: now).components.seconds)
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    /// `template` with `{time}` replaced by `remainingLabel`: "Offer ends in
    /// 9:58".
    public func endsInLabel(at now: Date? = nil, template: String) -> String {
        template.replacingOccurrences(of: "{time}", with: remainingLabel(at: now))
    }
}
