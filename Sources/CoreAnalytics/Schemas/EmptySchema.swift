//
//  EmptySchema.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

///
/// EmptySchema is a schema that should be used when the event contains no parameters.
///
struct EmptySchema: ParametersSchema {
    var source: EventSource
    
    init(source: EventSource) {
        self.source = source
    }
    
    func build() -> Parameters {
        build([
            "source": source.value
        ])
    }
}
