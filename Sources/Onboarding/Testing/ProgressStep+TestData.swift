//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 18.09.24.
//

import Foundation

extension ProgressStep {

    static func testData() -> Self {
        ProgressStep(
            title: "We're creating your plan...",
            duration: 15,
            steps: [
                "Analysing your answers",
                "Calculating your calorie goal",
                "Predicting your progress",
                "Adding finishing touches"
            ],
            answer: StepAnswer(title: "Continue")
        )
    }
}
