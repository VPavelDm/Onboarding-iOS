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
    public var accentColor: Color = .blue
}

