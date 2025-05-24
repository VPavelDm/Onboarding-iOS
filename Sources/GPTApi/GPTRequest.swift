//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 24.05.25.
//

import Foundation
import CoreNetwork

public extension Resource where Value: Codable {

    static func openAIRequest(body: GPTRequestBody) -> Self {
        Resource { _ in
            guard let url = URL(string: "https://calories.faulingo-app.workers.dev") else {
                throw URLError(.badURL)
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            try request.setHTTPBody(.json(body))
            return request
        } transform: { data, response in
            let response = try JSONDecoder().decode(GPTResponse.self, from: data)
            guard let content = response.choices.first?.message.content else {
                throw GPTApiClientError.invalidResponse
            }
            guard let data = content.data(using: .utf8) else {
                throw GPTApiClientError.dataFormat
            }
            return try JSONDecoder().decode(Value.self, from: data)
        }
    }

    enum GPTApiClientError: Error {
        case invalidResponse
        case urlFormat
        case dataFormat
    }
}
