//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import Foundation

public struct OnboardingConfiguration {

    let url: URL
    let bundle: Bundle
    let tableName: String?

    public init(url: URL, bundle: Bundle = .main, tableName: String? = nil) {
        self.url = url
        self.bundle = bundle
        self.tableName = tableName
    }
}
