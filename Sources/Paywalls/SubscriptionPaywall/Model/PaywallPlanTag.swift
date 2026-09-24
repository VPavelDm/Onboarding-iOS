//
//  PaywallPlanTag.swift
//  onboarding-ios
//
//  Created by Claude on 24.09.26.
//

import Foundation

/// The label riding a plan tile's top edge.
enum PaywallPlanTag: Hashable {
    /// The host's featured plan.
    case popular
    /// Whole-number saving against the priciest plan per day.
    case savings(Int)
}
