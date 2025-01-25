//
//  AnalyticsProtocol.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

public protocol AnalyticsProtocol {

    func track(event: Event)
    
    func setupUserProperties(_ params: Parameters)
}
