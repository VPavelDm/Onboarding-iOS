//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 21.09.24.
//

import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
#endif

extension Publisher where Self.Failure == Never {

    public func asyncSink(receiveValue: @escaping ((Output) async -> Void)) -> AnyCancellable {
        sink { output in
            Task { @MainActor in
                await receiveValue(output)
            }
        }
    }
}
