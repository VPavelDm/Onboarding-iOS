//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 08.09.24.
//

import Foundation

extension WelcomeStep {

    static func testData() -> Self {
        Self(
            title: "Welcome to Lyncil",
            description: "Unleash Your Songwriting Potential with Lyncil",
            image: .named("womanWithTeleskope")
        )
    }
}
