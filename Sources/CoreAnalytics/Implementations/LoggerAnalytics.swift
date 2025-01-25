//
//  LoggerAnalytics.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

struct LoggerAnalytics: AnalyticsProtocol {
    
    func track(event: Event) {
        if let event = event as? AnyEvent {
            print("Track Event: \(event.name)\(event.parameters.isEmpty ? "" : ", params - \(event.parameters)")")
        }
    }
    
    func setupUserProperties(_ params: Parameters) {
    }
}
