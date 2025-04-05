//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import SwiftUI

struct MockOnboardingView: View {

    var body: some View {
        OnboardingView(
            configuration: .testData(),
            delegate: MockOnboardingDelegate(onAnswerCallback: {}),
            colorPalette: .testData
        )
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MockOnboardingView()
}
