//
//  String+Localization.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import Foundation

struct Localizer {
    let bundle: Bundle
    let tableName: String?

    func localize(_ key: String) -> String {
        NSLocalizedString(key, tableName: tableName, bundle: bundle, value: key, comment: "")
    }
}

extension String {

    func localized(using localizer: Localizer) -> String {
        localizer.localize(self)
    }
}
