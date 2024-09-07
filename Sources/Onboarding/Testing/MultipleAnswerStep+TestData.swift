//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import Foundation

extension MultipleAnswerStep {

    static func testData() -> Self {
        Self(
            title: "What challenges did you face?",
            description: "Choose at least one option",
            answers: [
                "🍟 Resting cravings",
                "✨ Staying motivated",
                "🥣 Reducing portion sizes",
                "🥗 Knowing what to eat",
                "⏰ Being too busy",
                "💭 Something else",
            ]
        )
    }
}
