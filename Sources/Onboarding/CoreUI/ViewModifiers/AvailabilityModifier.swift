//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import SwiftUI

extension View {

    func applyIf(@ViewBuilder transform: (Self) -> some View) -> some View {
        transform(self)
    }
}
