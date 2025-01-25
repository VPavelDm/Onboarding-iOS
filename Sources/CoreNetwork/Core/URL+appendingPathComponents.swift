//
//  URL+appendingPathComponents.swift
//  CoreNetwork
//
//  Created by Pavel Vaitsikhouski on 04.09.24.
//

import Foundation

extension URL {

    public func appendingPathComponents(_ components: String...) -> URL {
        components.reduce(self) { $0.appendingPathComponent($1) }
    }
}
