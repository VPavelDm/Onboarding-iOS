//
//  AnyEvent.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

/**
  A type-erased Event that every tracking system can track. This is provided to:
  * Enable simple tracking in trivial cases, such as when just an event name is sent.
*/
public struct AnyEvent: Event {
    public let name: String
    public let parameters: Parameters

    public init(name: String, schema: ParametersSchema) {
        self.name = name
        self.parameters = schema.build()
    }
    
    public init(name: String, source: EventSource) {
        self.name = name
        self.parameters = EmptySchema(source: source).build()
    }
}
