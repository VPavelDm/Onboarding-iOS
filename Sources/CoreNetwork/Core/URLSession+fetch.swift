//
//  URLSession+fetch.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

/// Function to use to sign network requests.
public var authenticate: (URLRequest, @escaping (URLRequest) -> Void) -> Void = { request, completion in
    completion(request)
}

/// Modifiers that are performed for every network request made.
public var modifiers: [NetworkModifier] = []

extension URLSession {

    /// Fetches the given resource using its `makeRequest` function to create
    /// the URL request and its `transform` function to create the value to
    /// return.
    ///
    /// - Parameters:
    ///   - resource: The resource to fetch.
    ///   - queue: The queue to callback onto. Default is `DispatchQueue.main`.
    ///   - completion: Completion block to call once the request has been performed.
    public func fetch<Value>(
        _ resource: Resource<Value>,
        callbackQueue queue: DispatchQueue = .main,
        completion: @escaping (Result<Value, Error>) -> Void
    ) {
        do {
            let resource = resource.modify(modifiers)

            authenticate(try resource.makeRequest(ResourceInitialiser.shared.networkEnvironment)) { request in
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
        completion: @escaping (Result<(Data, URLResponse), URLError>) -> Void
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
