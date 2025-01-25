//
//  CompositeAnalytics.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

struct CompositeAnalytics: AnalyticsProtocol {
    
    private let analytics: [AnalyticsProtocol]
    
    init(analytics: [AnalyticsProtocol]) {
        self.analytics = analytics
    }
    
    func track(event: Event) {
        analytics.forEach { $0.track(event: event) }
    }
    
    func setupUserProperties(_ params: Parameters) {
        analytics.forEach { $0.setupUserProperties(params) }
    }
}
