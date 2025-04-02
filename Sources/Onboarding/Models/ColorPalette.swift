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

@available(iOS 18.0, *)
public extension ColorPalette where Self == TestColorPalette {

    static func testData(isAnimating: Binding<Bool>) -> Self {
        TestColorPalette(isAnimating: isAnimating)
    }
}

@available(iOS 18.0, *)
public struct TestColorPalette: ColorPalette {
    public typealias BackgroundView = AffirmationBackgroundView
    public var backgroundView: BackgroundView
    public var textColor: Color = .white
    public var secondaryTextColor: Color = .secondary
    public var primaryButtonForegroundColor: Color = .white
    public var primaryButtonBackgroundColor: Color = Color(red: 90/255, green: 70/255, blue: 200/255)
    public var secondaryButtonForegroundColor: Color = .white
    public var secondaryButtonBackgroundColor: Color = Color(red: 90/255, green: 70/255, blue: 200/255).opacity(0.2)
    public var secondaryButtonStrokeColor: Color = Color(red: 90/255, green: 70/255, blue: 200/255).opacity(0.2)
    public var plainButtonColor: Color = .white
    public var progressBarBackgroundColor: Color = Color(red: 90/255, green: 70/255, blue: 200/255)
    public var orbitColor: Color = Color(uiColor: .systemGray6)
    public var accentColor: Color = Color(uiColor: .systemYellow)

    init(isAnimating: Binding<Bool>) {
        self.backgroundView = AffirmationBackgroundView(isAnimating: isAnimating)
    }
}

#Preview {
    MockOnboardingView()
}
