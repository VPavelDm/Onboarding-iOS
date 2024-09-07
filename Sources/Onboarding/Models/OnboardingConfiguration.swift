//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import Foundation

public struct OnboardingConfiguration {

    let url: URL
    let colorPalette: ColorPalette
    let bundle: Bundle

    public init(url: URL, colorPalette: ColorPalette, bundle: Bundle = .main) {
        self.url = url
        self.colorPalette = colorPalette
        self.bundle = bundle
    }
}
