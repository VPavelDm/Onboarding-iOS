//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 30.03.25.
//

import SwiftUI

struct RemoveBackgroundModifier: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .containerBackground(.clear, for: .navigation)
        } else {
            content
        }
    }
}

extension View {

    func removeBackground() -> some View {
        modifier(RemoveBackgroundModifier())
    }
}
