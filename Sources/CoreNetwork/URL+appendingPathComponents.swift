//
//  URL+appendingPathComponents.swift
//  VirtualChampionsLeague
//
//  Created by Pavel Vaitsikhouski on 17.10.22.
//

import Foundation

extension URL {

    public func appendingPathComponents(_ components: String...) -> URL {
        components.reduce(self) { $0.appendingPathComponent($1) }
    }
}
