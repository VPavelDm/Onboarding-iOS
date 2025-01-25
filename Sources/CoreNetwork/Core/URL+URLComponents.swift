//
//  URL+URLComponents.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

extension URL {
    
    public mutating func modify(_ modification: (inout URLComponents) -> Void) throws {
        struct URLModificationFailure: Error {}
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw URLModificationFailure()
        }
        modification(&components)
        guard let url = components.url else {
            throw URLModificationFailure()
        }
        self = url
    }
}
