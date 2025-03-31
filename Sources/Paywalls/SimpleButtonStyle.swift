//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.03.25.
//

import SwiftUI

struct SimpleButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
