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

    static var testData: Self {
        TestColorPalette()
    }
}

@available(iOS 18.0, *)
public struct TestColorPalette: ColorPalette {
    public typealias BackgroundView = AffirmationBackgroundView
    public var backgroundView: BackgroundView = AffirmationBackgroundView()
    public var textColor: Color = .white
    public var secondaryTextColor: Color = .secondary
    public var primaryButtonForegroundColor: Color = .black
    public var primaryButtonBackgroundColor: Color = Color(red: 108/255, green: 71/255, blue: 214/255)
    public var secondaryButtonForegroundColor: Color = .white
    public var secondaryButtonBackgroundColor: Color = Color(uiColor: .systemGray3)
    public var secondaryButtonStrokeColor: Color = Color(uiColor: .systemGray6)
    public var plainButtonColor: Color = .primary
    public var progressBarBackgroundColor: Color = Color(uiColor: .systemGray6)
    public var orbitColor: Color = Color(uiColor: .systemGray6)
    public var accentColor: Color = Color(uiColor: .systemYellow)
}
