//
//  Environments.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 30.01.24.
//

import Foundation

public enum NetworkEnvironment {
    case develop
    case production
    case local
}

public enum APIVersion: String {
    case v1
}

public var networkEnvironment: NetworkEnvironment {
    NetworkEnvironmentFactory.shared.networkEnvironment
}

public final class NetworkEnvironmentFactory: @unchecked Sendable {
    
    public static let shared = NetworkEnvironmentFactory()
    
    #if DEBUG
    public var networkEnvironment = NetworkEnvironment.develop
    #else
    public var networkEnvironment = NetworkEnvironment.production
    #endif
    
}

extension NetworkEnvironment {
    
    public var url: URL { self.url(.v1) }
    
    public func url(_ version: APIVersion) -> URL {
        baseURL.appendingPathComponents("/\(version.rawValue)")
    }

    private var baseURL: URL {
        switch self {
        case .production: return .production
        case .develop: return .develop
        case .local: return .local
        }
    }
}

// MARK: -

private extension URL {
    static let production = URL(string: "https://api.faulingo.com")!
    static let develop = URL(string: "https://api.faulingo.com")!
    static let local = URL(string: "http://localhost:8083")!
}
