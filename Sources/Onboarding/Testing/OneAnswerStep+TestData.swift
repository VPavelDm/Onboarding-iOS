//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

extension OneAnswerStep {

    static func testData() -> Self {
        Self(
            title: "What's your main goal?",
            description: "Choose only one answer",
            answers: [
                "📉 Lose weight",
                "👀 Maintain weight",
                "📈 Gain weight",
                "💪 Build weight",
                "💬 Something else",
            ]
        )
    }
}
