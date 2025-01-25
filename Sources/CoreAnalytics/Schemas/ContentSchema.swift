//
//  ContentSchema.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

///
/// ContentSchema is a schema that should be used when the event contains one parameter.
///
/// - Parameter content: the content which should be sent with the event.
///
public struct ContentSchema: ParametersSchema {
    var content: String
    var source: EventSource
    
    public init(content: String, source: EventSource) {
        self.content = content
        self.source = source
    }
    
    public func build() -> Parameters {
        build([
            "content": content,
            "source": source.value
        ])
    }
}
