//
//  PaywallTab.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation

/// One tab of a tabbed paywall (`PaywallTabsViewModel`): the host's id for
/// it, which its plans are matched to (`PaywallTabRule`) and its events are
/// stamped with; its title on the segmented control, already localized by
/// the host; and the paywall it shows.
public struct PaywallTab: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let configuration: PaywallConfiguration

    public init(id: String, title: String, configuration: PaywallConfiguration) {
        self.id = id
        self.title = title
        self.configuration = configuration
    }
}
