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
            image: ImageMeta(imageType: .named("songwriting_2"), aspectRatioType: "fill"),
            title: "Awesome! That's a great starting point.",
            description: "Studies have shown that regularly tracking your calories is directly linked to the self-motivation needed to successfully lose weight!", 
            answer: StepAnswer(
                title: "Continue",
                nextStepID: StepID("sex")
            )
        )
    }
}
