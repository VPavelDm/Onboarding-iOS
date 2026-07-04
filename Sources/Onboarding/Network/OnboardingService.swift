//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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

    /// Decodes the steps as raw keys. Localisation happens later, in the step
    /// views, via the delegate — so the flow stays language-agnostic here.
    func fetchSteps() async throws -> [OnboardingStep] {
        let (data, _) = try await session.data(from: configuration.url)
        let responses = try JSONDecoder().decode([OnboardingStepResponse].self, from: data)
        return responses.compactMap(OnboardingStep.init(response:))
    }
}
