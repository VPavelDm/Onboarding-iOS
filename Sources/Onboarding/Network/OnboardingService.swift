//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import Foundation

final class OnboardingService {

    // MARK: - Properties

    let configuration: OnboardingConfiguration
    let session: URLSession

    // MARK: - Inits

    init(configuration: OnboardingConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
    }

    // MARK: - Intents

    func fetchSteps() async throws -> [OnboardingStep] {
        let (data, _) = try await session.data(from: configuration.url)
        let steps = try JSONDecoder().decode([OnboardingStepResponse].self, from: data)
        return steps.compactMap(OnboardingStep.init(response:))
    }
}
