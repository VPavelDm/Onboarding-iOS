//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 14.08.25.
//

import Foundation

public protocol RemoteConfig {
    func load() async throws
    func config<T>(for key: ConfigKey<T>) -> T?
}
