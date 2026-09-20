//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import Foundation

extension TimePickerStep {

    static func testData() -> Self {
        TimePickerStep(
            title: "When do you want to study?",
            answer: StepAnswer(title: "Choose")
        )
    }
}
