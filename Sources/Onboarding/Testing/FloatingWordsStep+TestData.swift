//
//  FloatingWordsStep+TestData.swift
//  onboarding-ios
//

import Foundation

extension FloatingWordsStep {

    static func testData() -> Self {
        Self(
            title: "Are you forgetting words too quickly?",
            description: "You study new words on Monday. By Friday, most are gone.",
            caption: "And it's not your fault.",
            centralWord: "der Hund",
            centralTranslation: "the dog",
            floatingWords: ["Apfel", "schön", "lieben", "gehen", "Buch", "Verantwortung"],
            answer: StepAnswer(
                title: "Help me remember",
                nextStepID: StepID("intro")
            )
        )
    }
}
