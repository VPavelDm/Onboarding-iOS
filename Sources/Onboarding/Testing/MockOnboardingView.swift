//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import SwiftUI

struct MockOnboardingView: View {

    var body: some View {
        if #available(iOS 18.0, *) {
            OnboardingView(
                configuration: .testData(),
                delegate: MockOnboardingDelegate(onAnswerCallback: {
                }),
                colorPalette: .testData
            )
            .preferredColorScheme(.dark)
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    MockOnboardingView()
}
