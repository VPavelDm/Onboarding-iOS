//
//  PaywallPurchaseOutcome.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import Foundation

/// The result of attempting a purchase, abstracted from the store SDK.
public enum PaywallPurchaseOutcome: Sendable {
    case purchased
    case cancelled
    case notEntitled
    /// The purchase awaits approval outside the app (Ask to Buy / deferred payment).
    /// If approved, the entitlement arrives out of band; hosts should observe their
    /// subscription state to unlock.
    case pending
    /// The payload is a diagnostic for analytics, never shown to the user.
    case failed(String)
}
