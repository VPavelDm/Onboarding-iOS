//
//  Event.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

public protocol Event {}

public typealias Parameters = [String: Any]

public extension Parameters {

    static func + (lhs: Self, rhs: Self) -> Self {
        lhs.merging(rhs) { lhs, _ in lhs }
    }
}
