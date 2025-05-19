//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 19.05.25.
//

import Foundation

public extension Bundle {

    var isTestFlight: Bool {
#if DEBUG
        true
#else
        appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" || appStoreReceiptURL?.pathComponents.first(where: { $0 == "CoreSimulator" }) != nil
#endif
    }
}
