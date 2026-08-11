//
//  PaywallDismissBehavior.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import Foundation

/// Opts the paywall out of being hard: a corner close button fades in after
/// `closeButtonDelay`, and an optional named decline button appears above the footer
/// on the same beat — one "you may now leave" moment, expressed two ways, so the
/// dwell isn't quietly bypassed by the named action.
///
/// `onDismiss` runs for both; the view model tracks close and decline separately
/// (`paywall_close_button_tapped` vs `paywall_declined`) so analytics can tell "bailed
/// out" from "chose the free path".
public struct PaywallDismissBehavior {

    public let closeButtonDelay: Duration
    /// Title for an explicit decline button (e.g. "Seal it as words only"), or nil
    /// for the corner close button alone.
    public let declineTitle: String?
    public let onDismiss: @MainActor () -> Void

    public init(
        closeButtonDelay: Duration = .seconds(2),
        declineTitle: String? = nil,
        onDismiss: @escaping @MainActor () -> Void
    ) {
        self.closeButtonDelay = closeButtonDelay
        self.declineTitle = declineTitle
        self.onDismiss = onDismiss
    }
}
