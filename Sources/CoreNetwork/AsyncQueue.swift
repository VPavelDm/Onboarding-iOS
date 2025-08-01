//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 01.08.25.
//

import Foundation

public actor AsyncQueue {
    private var nextOperation: (() async -> Void)?
    public private(set) var isPending = false

    public init() {}

    // MARK: - Intents

    public func submit(operation: @escaping () async -> Void) async {
        nextOperation = operation
        if !isPending {
            isPending = true
            await runOperation()
            isPending = false
        }
    }

    private func runOperation() async {
        let nextOperation = nextOperation
        self.nextOperation = nil

        await nextOperation?()

        if self.nextOperation != nil {
            await runOperation()
        }
    }
}
