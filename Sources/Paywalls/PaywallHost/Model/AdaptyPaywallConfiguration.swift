//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 04.05.25.
//

import Foundation
import Adapty
import AdaptyUI

enum AdaptyPaywallConfiguration {
    case paywallConfiguration(AdaptyUI.PaywallConfiguration)
    case remoteConfig([AdaptyPaywallProduct], AdaptyPaywall)
}
