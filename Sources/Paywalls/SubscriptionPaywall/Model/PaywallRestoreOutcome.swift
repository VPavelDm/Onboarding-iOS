//
//  PaywallRestoreOutcome.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import Foundation

/// The result of restoring purchases, abstracted from the store SDK.
public enum PaywallRestoreOutcome: Sendable {
    case restored
    case notEntitled
    case failed
}
