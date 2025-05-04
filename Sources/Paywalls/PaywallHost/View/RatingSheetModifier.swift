//
//  RatingSheetModifier.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 04.05.25.
//

import SwiftUI
import StoreKit

struct RatingSheetModifier: ViewModifier {

    @Environment(\.requestReview) var requestReview

    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    requestReview()
                    isPresented = false
                }
            }
    }
}

extension View {

    func ratingSheet(isPresented: Binding<Bool>) -> some View {
        modifier(RatingSheetModifier(isPresented: isPresented))
    }
}
