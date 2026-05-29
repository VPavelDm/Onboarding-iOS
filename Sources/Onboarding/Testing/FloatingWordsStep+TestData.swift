#if !os(Android)
//
//  FloatingWordsStep+TestData.swift
//  onboarding-ios
//

import Foundation

extension FloatingWordsStep {

    static func testData() -> Self {
        Self(
            centralWord: "der Hund",
            centralTranslation: "the dog",
            floatingWords: ["Apfel", "schön", "lieben", "gehen", "Buch", "Verantwortung"],
            nextStepID: StepID("intro")
        )
    }
}
#endif
