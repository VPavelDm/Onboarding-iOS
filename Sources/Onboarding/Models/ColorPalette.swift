//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 07.02.25.
//

import SwiftUI

public protocol ColorPalette {
    var textColor: Color { get }
    var secondaryTextColor: Color { get }
    var primaryButtonForegroundColor: Color { get }
    var primaryButtonBackground: AnyShapeStyle { get }
    var secondaryButtonForegroundColor: Color { get }
    var secondaryButtonBackground: AnyShapeStyle { get }
    var secondaryButtonStrokeColor: Color { get }
    var plainButtonColor: Color { get }
    var progressBarBackgroundColor: AnyShapeStyle { get }
    var orbitColor: Color { get }
    var accentColor: Color { get }
    var ratingStarColor: Color { get }
}

public extension ColorPalette {
    var ratingStarColor: Color { Color(red: 0.82, green: 0.65, blue: 0.2) }
}

extension ColorPalette where Self == TestColorPalette {

    static var testData: Self {
        TestColorPalette()
    }
}

struct TestColorPalette: ColorPalette {
    var textColor: Color = .white
    var secondaryTextColor: Color = .secondary
    var primaryButtonForegroundColor: Color = .black
    var primaryButtonBackground: AnyShapeStyle = AnyShapeStyle(Color.yellow)
    var secondaryButtonForegroundColor: Color = .white
    var secondaryButtonBackground: AnyShapeStyle = AnyShapeStyle(.ultraThinMaterial)
    var secondaryButtonStrokeColor: Color = Color.white.opacity(0.15)
    var plainButtonColor: Color = .primary
    var progressBarBackgroundColor: AnyShapeStyle = AnyShapeStyle(.ultraThinMaterial)
    var orbitColor: Color = Color.gray.opacity(0.2)
    var accentColor: Color = Color.yellow
    var ratingStarColor: Color = Color(red: 0.82, green: 0.65, blue: 0.2)
}

#if !os(Android)
#Preview {
    MockOnboardingView()
}
#endif
