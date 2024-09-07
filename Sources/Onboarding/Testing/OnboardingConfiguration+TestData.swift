//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import Foundation

public extension OnboardingConfiguration {

    static func testData() -> Self {
        Self(
            url: Bundle.module.url(forResource: "onboarding_steps", withExtension: "json")!,
            colorPalette: .testData,
            bundle: .module
        )
    }
}
