//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import Foundation

extension BinaryAnswerStep {

    static func testData() -> Self {
        Self(
            title: "What's your sex?",
            description: "Since the formula for an accurate calorie calculation differs based on sex, we need this information to calculate your daily calorie goal.",
            firstAnswer: Answer(
                text: "Female",
                icon: "🚺"
            ),
            secondAnswer: Answer(
                text: "Male",
                icon: "🚹"
            )
        )
    }
}
