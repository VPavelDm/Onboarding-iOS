//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 04.05.25.
//

import Foundation

@MainActor
public protocol PaywallHostDelegate: AnyObject {
    func fetchSubscriptionStatus() async throws
    func track(event: String, parameters: [String: Any])
}
