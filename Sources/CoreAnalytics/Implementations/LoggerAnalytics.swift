//
//  LoggerAnalytics.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

public struct LoggerAnalytics: AnalyticsProtocol {

    public init() {}

    public func track(event: Event) {
        if let event = event as? AnyEvent {
            print("Track Event: \(event.name)\(event.parameters.isEmpty ? "" : ", params - \(event.parameters)")")
        }
    }
    
    public func setupUserProperties(_ params: Parameters) {
    }
}
