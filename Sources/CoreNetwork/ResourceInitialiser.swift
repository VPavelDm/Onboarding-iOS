//
//  ResourceInitialiser.swift
//
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

public final class ResourceInitialiser {

    private var _networkEnvironment: NetworkEnvironment?
    var networkEnvironment: NetworkEnvironment {
        get throws {
            struct NetworkEnvironmentIsNotInitialisedError: Error {}
            guard let _networkEnvironment else {
                throw NetworkEnvironmentIsNotInitialisedError()
            }
            return _networkEnvironment
        }
    }

    public static let shared = ResourceInitialiser()

    public func initialise(networkEnvironment: NetworkEnvironment) {
        self._networkEnvironment = networkEnvironment
    }
}
