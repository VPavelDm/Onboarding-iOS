//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import SwiftUI
import CoreUI

public struct ColorPalette: Sendable, AsyncButtonColorPalette, CheckBoxColorPalette {
    public let asyncButtonProgressView: Color
    public let checkboxBackground: Color
    public let checkboxCheckmark: Color
    let backgroundColor: Color
    let primaryTextColor: Color
    let secondaryTextColor: Color
    let primaryButtonTextColor: Color
    let primaryButtonBackgroundColor: Color
    let secondaryButtonTextColor: Color
    let secondaryButtonBackgroundColor: Color
    let progressBarColor: Color
    let progressBarBackgroundColor: Color

    public init(
        asyncButtonProgressView: Color,
        checkboxBackground: Color,
        checkboxCheckmark: Color,
        backgroundColor: Color,
        primaryTextColor: Color,
        secondaryTextColor: Color,
        primaryButtonTextColor: Color,
        primaryButtonBackgroundColor: Color,
        secondaryButtonTextColor: Color,
        secondaryButtonBackgroundColor: Color,
        progressBarColor: Color,
        progressBarBackgroundColor: Color
    ) {
        self.asyncButtonProgressView = asyncButtonProgressView
        self.checkboxBackground = checkboxBackground
        self.checkboxCheckmark = checkboxCheckmark
        self.backgroundColor = backgroundColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryButtonBackgroundColor = primaryButtonBackgroundColor
        self.secondaryButtonTextColor = secondaryButtonTextColor
        self.secondaryButtonBackgroundColor = secondaryButtonBackgroundColor
        self.progressBarColor = progressBarColor
        self.progressBarBackgroundColor = progressBarBackgroundColor
    }
}

// MARK: - Environment

struct ColorPaletteKey: EnvironmentKey {
    static let defaultValue: ColorPalette = .testData
}

extension EnvironmentValues {
    var colorPalette: ColorPalette {
        get { self[ColorPaletteKey.self] }
        set { self[ColorPaletteKey.self] = newValue }
    }
}
