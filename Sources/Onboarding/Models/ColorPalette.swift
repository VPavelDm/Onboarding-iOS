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
    /// What marks a chosen option everywhere in the flow: answer rows, radios, grid tiles,
    /// chips, the stepper's position. Nil keeps each control's colour from before 4.7 (the
    /// accent for tiles, chips and the stepper; the primary button's for answers and radios).
    var selectionColor: Color? { get }
    /// The moments the flow wants the eye on: the milestone timeline's dots, the path between
    /// them and the word riding it, the receipt's total line and stamp, the progress step's laurels, and the notification
    /// banner's app-icon tile. Nil keeps each one as before 4.7.
    var highlightColor: Color? { get }
    /// What fills as the user moves forward: the progress-bars step and the commitment hold's
    /// ring and committed disc. Nil uses the accent, as before 4.7.
    var progressColor: Color? { get }
}

public extension ColorPalette {
    var ratingStarColor: Color { Color(red: 0.82, green: 0.65, blue: 0.2) }
    var selectionColor: Color? { nil }
    var highlightColor: Color? { nil }
    var progressColor: Color? { nil }
}

extension ColorPalette {
    /// The highlight colour, or the accent where the host sets none.
    var highlightTint: Color { highlightColor ?? accentColor }
    /// The progress colour, or the accent where the host sets none.
    var progressTint: Color { progressColor ?? accentColor }
    /// The selection colour for controls that used the accent.
    var selectionTint: Color { selectionColor ?? accentColor }
    /// The selection colour for controls that used the primary button's fill.
    var answerSelectionStyle: AnyShapeStyle {
        selectionColor.map { AnyShapeStyle($0) } ?? primaryButtonBackground
    }
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

#Preview {
    MockOnboardingView()
}
