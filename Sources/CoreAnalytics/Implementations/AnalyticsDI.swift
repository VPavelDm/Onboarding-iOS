//
//  AnalyticsDI.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

public final class AnalyticsDI {

    @MainActor
    public static let shared = AnalyticsDI()
    public var implementations: [AnalyticsProtocol] = []

    private init() {}
    
    public var analytics: AnalyticsProtocol {
        var analytics: [AnalyticsProtocol] = implementations
        #if DEBUG
        analytics.append(LoggerAnalytics())
        #endif
        
        return CompositeAnalytics(analytics: analytics)
    }
}
