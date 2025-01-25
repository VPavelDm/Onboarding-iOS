//
//  HTTPError.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

/// Represents an HTTP error.
///
/// https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
public struct HTTPError: Error, Equatable, Hashable {
    public let code: Code
    public init(_ code: Code) {
        self.code = code
    }
}

extension HTTPError {

    public struct Code: Equatable, Hashable {
        let value: Int
        public init(_ value: Int) {
            self.value = value
        }
    }
}

extension HTTPError {

    /// Throws an ``HTTPError`` if the response is an ``HTTPURLResponse`` and
    /// the status code is 400 or more.
    ///
    /// - Parameter response: The response to check.
    /// - Throws: An ``HTTPError``.
    public static func check(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        guard httpResponse.statusCode >= 400 else { return }
        throw HTTPError(Code(httpResponse.statusCode))
    }
}

/// Function to allow pattern-matching on HTTPError with an Error
///
/// For example this allows you to switch on a thrown error to match to a
/// specific HTTPError.
public func ~= (lhs: HTTPError, rhs: Error) -> Bool {
    guard let error = rhs as? HTTPError else { return false }
    return error == lhs
}

// MARK: - HTTP Error Codes

extension HTTPError.Code {

    public static let badRequest = HTTPError.Code(400)
    public static let unauthorized = HTTPError.Code(401)
    public static let paymentRequired = HTTPError.Code(402)
    public static let forbidden = HTTPError.Code(403)
    public static let notFound = HTTPError.Code(404)
    public static let methodNotAllowed = HTTPError.Code(405)
    public static let notAcceptable = HTTPError.Code(406)
    public static let proxyAuthenticationRequired = HTTPError.Code(407)
    public static let requestTimeout = HTTPError.Code(408)
    public static let conflict = HTTPError.Code(409)
    public static let gone = HTTPError.Code(410)
    public static let lengthRequired = HTTPError.Code(411)
    public static let preconditionFailed = HTTPError.Code(412)
    public static let requestEntityTooLarge = HTTPError.Code(413)
    public static let requestURITooLong = HTTPError.Code(414)
    public static let unsupportedMediaType = HTTPError.Code(415)
    public static let requestedRangeNotSatisfiable = HTTPError.Code(416)
    public static let expectationFailed = HTTPError.Code(417)
    public static let unprocessableEntity = HTTPError.Code(422)

    public static let internalServerError = HTTPError.Code(500)
    public static let notImplemented = HTTPError.Code(501)
    public static let badGateway = HTTPError.Code(502)
    public static let serviceUnavailable = HTTPError.Code(503)
    public static let gatewayTimeout = HTTPError.Code(504)
    public static let httpVersionNotSupported = HTTPError.Code(505)
}

// MARK: - CustomStringConvertible

extension HTTPError: CustomStringConvertible {

    public var description: String {
        return "HTTP Error \(code)"
    }
}

extension HTTPError.Code: CustomStringConvertible {

    public var description: String {
        let name = HTTPURLResponse.localizedString(forStatusCode: value)
        return "\(value) \(name)"
    }
}
