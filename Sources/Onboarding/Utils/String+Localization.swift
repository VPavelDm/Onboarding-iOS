//
//  String+Localization.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 31.01.26.
//

import Foundation

extension String {

    /// Resolves a localization key to a localized string using the specified bundle.
    /// If the key is not found, returns the key itself.
    func localized(bundle: Bundle) -> String {
        let localized = NSLocalizedString(self, bundle: bundle, comment: "")
        return localized
    }
}
