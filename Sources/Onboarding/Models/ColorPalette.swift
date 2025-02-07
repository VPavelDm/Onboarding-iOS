//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 07.02.25.
//

import SwiftUI

public protocol ColorPalette {
    var backgroundHexColor: String { get }
    var textHexColor: String { get }
    var secondaryTextHexColor: String { get }
    var primaryButtonForegroundHexColor: String { get }
    var primaryButtonBackgroundHexColor: String { get }
    var primaryButtonDisabledBackgroundHexColor: String { get }
}

public extension ColorPalette {

    var backgroundColor: Color {
        Color(hex: backgroundHexColor)
    }

    var textColor: Color {
        Color(hex: textHexColor)
    }

    var secondaryTextColor: Color {
        Color(hex: secondaryTextHexColor)
    }

    var primaryButtonForegroundColor: Color {
        Color(hex: primaryButtonForegroundHexColor)
    }

    var primaryButtonBackgroundColor: Color {
        Color(hex: primaryButtonBackgroundHexColor)
    }

    var primaryButtonDisabledBackgroundColor: Color {
        Color(hex: primaryButtonDisabledBackgroundHexColor)
    }
}

public extension ColorPalette where Self == TestColorPalette {

    static var testData: Self {
        TestColorPalette()
    }
}

public struct TestColorPalette: ColorPalette {
    public var backgroundHexColor: String = ""
    public var textHexColor: String = ""
    public var secondaryTextHexColor: String = ""
    public var primaryButtonForegroundHexColor: String = ""
    public var primaryButtonBackgroundHexColor: String = ""
    public var primaryButtonDisabledBackgroundHexColor: String = ""
}

