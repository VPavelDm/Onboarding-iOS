//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import SwiftUI

extension View {

    func apply(@ViewBuilder transform: (Self) -> some View) -> some View {
        transform(self)
    }
}
