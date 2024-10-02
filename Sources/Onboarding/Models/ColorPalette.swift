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
    public let backgroundColor: Color
    public let primaryTextColor: Color
    public let secondaryTextColor: Color
    public let primaryButtonTextColor: Color
    public let primaryButtonBackgroundColor: Color
    public let secondaryButtonTextColor: Color
    public let secondaryButtonBackgroundColor: Color
    public let progressBarColor: Color
    public let progressBarBackgroundColor: Color
    public let progressBarDisabledColor: Color
    public let orbitColor: Color
    public let discountSliceDarkColor: Color
    public let discountSliceLightColor: Color
    public let discountSliceGiftColor: Color

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
        progressBarBackgroundColor: Color,
        progressBarDisabledColor: Color,
        orbitColor: Color,
        discountSliceDarkColor: Color,
        discountSliceLightColor: Color,
        discountSliceGiftColor: Color
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
        self.progressBarDisabledColor = progressBarDisabledColor
        self.orbitColor = orbitColor
        self.discountSliceDarkColor = discountSliceDarkColor
        self.discountSliceLightColor = discountSliceLightColor
        self.discountSliceGiftColor = discountSliceGiftColor
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
