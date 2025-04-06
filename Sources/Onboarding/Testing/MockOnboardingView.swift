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
            colorPalette: .testData,
            customStepView: { params in
                switch params.currentStepID {
                case "appHome":
                    Text(verbatim: "appHome")
                case "voices":
                    AsyncButton {
                        await params()
                    } label: {
                        Text(verbatim: "Choose")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                default:
                    EmptyView()
                }
            }
        )
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MockOnboardingView()
}
