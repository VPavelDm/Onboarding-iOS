//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 14.08.25.
//

import Foundation

public struct ConfigKey<Value> {
    public typealias KeyName = String
    public typealias MakeValueBlock = (Data) throws -> Value

    public let name: KeyName
    public let makeValue: MakeValueBlock
}

public extension ConfigKey where Value == Void {

    init(name: KeyName) {
        self.name = name
        self.makeValue = { _ in }
    }
}

public extension ConfigKey where Value: Decodable {

    private static func decode(from jsonData: Data) throws -> Value {
        try JSONDecoder().decode(Value.self, from: jsonData)
    }

    init(name: KeyName) {
        self.init(name: name, makeValue: Self.decode(from:))
    }
}
