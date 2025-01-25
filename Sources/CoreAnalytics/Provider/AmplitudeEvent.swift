//
//  AmplitudeEvent.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

// MARK: - Event

public protocol AmplitudeEvent: Event {
    var details: AmplitudeEventDetails? { get }
}

public struct AmplitudeEventDetails {
    let name: String
    let parameters: Parameters

    public init(name: String, parameters: Parameters = [:]) {
        self.name = name
        self.parameters = parameters
    }
}
