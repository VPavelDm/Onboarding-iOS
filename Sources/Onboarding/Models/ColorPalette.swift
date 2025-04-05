//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 07.02.25.
//

import SwiftUI

public protocol ColorPalette {
    associatedtype BackgroundView: View
    var backgroundView: BackgroundView { get }
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

extension ColorPalette {

    var anyBackgroundView: AnyView {
        AnyView(backgroundView)
    }
}

extension ColorPalette where Self == TestColorPalette {

    static var testData: Self {
        TestColorPalette()
    }
}

struct TestColorPalette: ColorPalette {
    typealias BackgroundView = Color
    var backgroundView: Color = .black
    var textColor: Color = .white
    var secondaryTextColor: Color = .secondary
    var primaryButtonForegroundColor: Color = .black
    var primaryButtonBackgroundColor: Color = Color(uiColor: .systemYellow)
    var secondaryButtonForegroundColor: Color = .white
    var secondaryButtonBackgroundColor: Color = Color(uiColor: .systemGray6)
    var secondaryButtonStrokeColor: Color = Color(uiColor: .systemGray6)
    var plainButtonColor: Color = .primary
    var progressBarBackgroundColor: Color = Color(uiColor: .systemGray6)
    var orbitColor: Color = Color(uiColor: .systemGray6)
    var accentColor: Color = Color(uiColor: .systemYellow)
}

#Preview {
    MockOnboardingView()
}
