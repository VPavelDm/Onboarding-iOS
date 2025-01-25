//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 25.01.25.
//

import Foundation

public extension Array where Element == NetworkModifier {

    static func testModifiers(_ modifiers: NetworkModifier...) -> Self {
        return modifiers + [
            .testFail(where: { !$0.isFileURL })
        ]
    }
}

struct UnexpectedRequestFailure: Error {
    let request: URLRequest
}

public extension NetworkModifier {

    static func testFail(where predicate: @escaping (URL) -> Bool ) -> NetworkModifier {
        NetworkModifier(
            modifyRequest: { request in
                guard let url = request.url else { return }
                guard predicate(url) else { return }
                throw UnexpectedRequestFailure(request: request)
            }
        )
    }
}

public extension NetworkModifier {

    static func replace(
        _ method: String,
        _ path: String,
        with replacement: URL,
        response urlResponse: URLResponse
    ) -> Self {
        NetworkModifier(
            modifyRequest: { request in
                guard request.httpMethod == method else { return }
                guard let url = request.url, url.path.hasSuffix(path) else { return }
                request = URLRequest(url: replacement)
            },
            modifyResponse: { response in
                if response.1.url == urlResponse.url {
                    response.1 = urlResponse
                }
            }
        )
    }
}

public extension URLResponse {

    static func http(statusCode: Int, url: URL) -> URLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
