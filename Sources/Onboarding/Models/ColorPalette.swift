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
    public var textColor: Color = .primary
    public var secondaryTextColor: Color = .secondary
    public var primaryButtonForegroundColor: Color = .primary
    public var primaryButtonBackgroundColor: Color = Color(red: 108/255, green: 71/255, blue: 214/255)
    public var secondaryButtonForegroundColor: Color = .white
    public var secondaryButtonBackgroundColor: Color = .black
    public var secondaryButtonStrokeColor: Color = .blue
    public var plainButtonColor: Color = .white
    public var progressBarBackgroundColor: Color = .red
    public var orbitColor: Color = .gray
    public var accentColor: Color = .green
}
