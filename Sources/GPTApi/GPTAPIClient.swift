//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 11.05.25.
//

import Foundation

public final class GPTAPIClient {

    private let apiKey: String
    private let session: URLSession

    public init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    public func send<Model>(body: GPTRequestBody) async throws -> Model where Model: Codable {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw GPTApiClientError.urlFormat
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(GPTResponse.self, from: data)
        guard let content = response.choices.first?.message.content else {
            throw GPTApiClientError.invalidResponse
        }
        guard let data = content.data(using: .utf8) else {
            throw GPTApiClientError.dataFormat
        }
        return try JSONDecoder().decode(Model.self, from: data)
    }

    public enum GPTApiClientError: Error {
        case invalidResponse
        case urlFormat
        case dataFormat
    }
}
