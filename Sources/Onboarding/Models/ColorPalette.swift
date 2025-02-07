//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 07.02.25.
//

import SwiftUI

public protocol ColorPalette {
    var backgroundColor: Color { get }
    var textColor: Color { get }
    var secondaryTextColor: Color { get }
    var primaryButtonForegroundColor: Color { get }
    var primaryButtonBackgroundColor: Color { get }
    var secondaryButtonForegroundColor: Color { get }
    var secondaryButtonBackgroundColor: Color { get }
    var secondaryButtonStrokeColor: Color { get }
    var plainButtonColor: Color { get }
    var progressBarBackgroundColor: Color { get }
    var orbitColor: Color { get }
    var accentColor: Color { get }
}

public extension ColorPalette where Self == TestColorPalette {

    static var testData: Self {
        TestColorPalette()
    }
}

public struct TestColorPalette: ColorPalette {
    public var backgroundColor: Color = .black
    public var textColor: Color = .primary
    public var secondaryTextColor: Color = .secondary
    public var primaryButtonForegroundColor: Color = .primary
    public var primaryButtonBackgroundColor: Color = .blue
    public var secondaryButtonForegroundColor: Color = .blue
    public var secondaryButtonBackgroundColor: Color = .blue
    public var secondaryButtonStrokeColor: Color = .blue
    public var plainButtonColor: Color = .white
    public var progressBarBackgroundColor: Color = .red
    public var orbitColor: Color = .gray
    public var accentColor: Color = .blue
}

