//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import Foundation

extension DescriptionStep {

    static func testData() -> Self {
        Self(
            image: .named("womanWithTeleskope"),
            title: "Awesome! That's a great starting point.",
            description: "Studies have shown that regularly tracking your calories is directly linked to the self-motivation needed to successfully lose weight!", 
            answer: StepAnswer(
                title: "Continue",
                nextStepID: UUID(uuidString: "6021CABF-377B-4B9E-A488-1DF90888FDDD")
            )
        )
    }
}
