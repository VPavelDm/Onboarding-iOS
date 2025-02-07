//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 07.02.25.
//

import Foundation

public extension NetworkModifier {

    static func modifyAcceptLanguageHeader(_ bundle: Bundle = Bundle.main) -> Self {
        return NetworkModifier(modifyRequest: { request in
            request.addHTTPHeaderField(URLRequest.HTTPHeaderField(
                key: "Accept-Language",
                value: bundle.preferredLocalizations.first ?? ""
            ))
        })
    }
}
