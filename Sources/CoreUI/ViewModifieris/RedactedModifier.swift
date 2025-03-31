//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 28.09.24.
//

import SwiftUI

public extension View {

    @ViewBuilder
    func redacted(reason: RedactionReasons, if condition: @autoclosure () -> Bool) -> some View {
        redacted(reason: condition() ? reason : [])
    }
}
