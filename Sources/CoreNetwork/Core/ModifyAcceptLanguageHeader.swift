//
//  File.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

extension NetworkModifier {

    public static func modifyAcceptLanguageHeader(_ bundle: Bundle = Bundle.main) -> Self {
        return NetworkModifier(modifyRequest: { request in
            request.addHTTPHeaderField(URLRequest.HTTPHeaderField(
                key: "Accept-Language",
                value: bundle.preferredLocalizations.first ?? ""
            ))
        })
    }
}
