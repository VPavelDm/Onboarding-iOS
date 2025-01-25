//
//  AmplitudeAnalytics.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation
import Amplitude

public class AmplitudeAnalytics: AnalyticsProtocol {

    public func track(event: Event) {
        if let details = (event as? AmplitudeEvent)?.details {
            Amplitude.instance().logEvent(details.name, withEventProperties: details.parameters)
        }
    }
    
    public func setupUserProperties(_ params: Parameters) {
        Amplitude.instance().setUserProperties(params)
    }
}
