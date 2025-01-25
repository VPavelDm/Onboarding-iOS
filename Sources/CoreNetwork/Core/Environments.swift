//
//  Environments.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

public struct NetworkEnvironment {
    private var baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}

public enum APIVersion {
    case v1, v2, v3
    case other(String)

    var value: String {
        switch self {
        case .v1:
            "v1"
        case .v2:
            "v2"
        case .v3:
            "v3"
        case .other(let string):
            string
        }
    }
}

extension NetworkEnvironment {
    
    public var url: URL { self.url(.v1) }
    
    public func url(_ version: APIVersion) -> URL {
        baseURL.appendingPathComponents("/\(version.value)")
    }
}
