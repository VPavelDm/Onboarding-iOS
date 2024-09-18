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
            steps: [
                "Analysing your answers",
                "Calculating your calorie goal",
                "Predicting your progress",
                "Adding finishing touches"
            ]
        )
    }
}
