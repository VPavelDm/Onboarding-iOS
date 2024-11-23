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

    public init(url: URL, bundle: Bundle = .main) {
        self.url = url
        self.bundle = bundle
    }
}
