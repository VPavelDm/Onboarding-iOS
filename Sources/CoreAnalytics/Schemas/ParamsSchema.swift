//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 24.03.25.
//

import Foundation

public struct ParamsSchema: ParametersSchema {
    var params: Parameters

    public init(params: Parameters) {
        self.params = params
    }

    public func build() -> Parameters {
        build(params)
    }
}
