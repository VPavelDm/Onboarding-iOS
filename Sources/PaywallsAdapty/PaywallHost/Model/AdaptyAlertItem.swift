//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 04.05.25.
//

import SwiftUI

enum AdaptyAlertItem: Identifiable {
    var id: Self { self }

    case restoreError
    case purchaseError

    var title: LocalizedStringKey {
        "Error 🥲"
    }

    var message: LocalizedStringKey {
        switch self {
        case .restoreError:
            "Sorry, cannot find purchases to restore."
        case .purchaseError:
            "Payment is failed. Try again later!"
        }
    }
}

