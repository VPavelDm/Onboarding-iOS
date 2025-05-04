//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 04.05.25.
//

import Foundation
import Adapty
import AdaptyUI

struct AdaptyRemoteConfigPaywall: Identifiable {
    var id: String { "AdaptyRemoteConfigPaywall" }

    var products: [AdaptyPaywallProduct]
    var paywall: AdaptyPaywall
}

