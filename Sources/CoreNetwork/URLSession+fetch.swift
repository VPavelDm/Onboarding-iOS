//
//  URLSession+fetch.swift
//  VirtualChampionsLeague
//
//  Created by Pavel Vaitsikhouski on 17.10.22.
//

import Foundation

public final class AuthenticateFactory: @unchecked Sendable {
    public static let shared = AuthenticateFactory()
    
    /// Function to use to sign network requests.
    public var authenticate: (URLRequest, @escaping (URLRequest) -> Void) -> Void = { request, completion in
        completion(request)
    }
}

public final class ModifiersFactory: @unchecked Sendable {
    public static let shared = ModifiersFactory()
    
    /// Modifiers that are performed for every network request made.
    public var modifiers: [NetworkModifier] = []
}

extension URLSession {

    /// Fetches the given resource using its `makeRequest` function to create
    /// the URL request and its `transform` function to create the value to
    /// return.
    ///
    /// - Parameters:
    ///   - resource: The resource to fetch.
    ///   - queue: The queue to callback onto. Default is `DispatchQueue.main`.
    ///   - completion: Completion block to call once the request has been performed.
    public func fetch<Value: Sendable>(
        _ resource: Resource<Value>,
        callbackQueue queue: DispatchQueue = .main,
        completion: @Sendable @escaping (Result<Value, Error>) -> Void
    ) {
        do {
            let resource = resource.modify(ModifiersFactory.shared.modifiers)

            AuthenticateFactory.shared.authenticate(try resource.makeRequest()) { request in
                self.perform(request: request) { result in
                    let value = Result { try resource.transform(result.get()) }

                    queue.async { completion(value) }
                }
            }

        } catch {
            completion(.failure(error))
        }
    }

    @discardableResult
    private func perform(
        request: URLRequest,
        completion: @Sendable @escaping (Result<(Data, URLResponse), URLError>) -> Void
    ) -> URLSessionDataTask {

        let task = dataTask(with: request) { data, response, error in

            guard let data = data, let response = response else {
                let error = (error as? URLError) ?? URLError(.unknown)
                completion(.failure(error))
                return
            }
            completion(.success((data, response)))
        }

        task.resume()
        return task
    }
}
