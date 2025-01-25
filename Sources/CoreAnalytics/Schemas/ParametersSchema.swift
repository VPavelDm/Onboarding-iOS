//
//  ParametersSchema.swift
//  Faultier
//
//  Created by Pavel Vaitsikhouski on 21.01.24.
//

import Foundation

public protocol ParametersSchema {
    func build() -> Parameters
}

public extension ParametersSchema {
    
    func build(_ dict: [String: Any?]) -> Parameters {
        formatted(dict)
    }
    
    private func formatted(_ json: [String: Any?]) -> Parameters {
        var result = [String: Any]()
        for (key, value) in json {
            guard let value = value else {
                continue
            }
            var valueToAppend = value
            if let date = valueToAppend as? Date {
                valueToAppend = date.stringValue
            } else if let object = valueToAppend as? ParametersSchema {
                valueToAppend = object.build()
            } else if let array = valueToAppend as? [ParametersSchema] {
                guard !array.isEmpty else { continue }
                valueToAppend = array.map { $0.build() }
            } else if let dict = valueToAppend as? [String: Any] {
                let formattedDict = formatted(dict) as [String: Any]
                guard !formattedDict.isEmpty else { continue }
                valueToAppend = formattedDict
            } else if let array = valueToAppend as? Array<Any> {
                guard !array.isEmpty else { continue }
                valueToAppend = array
            }
            result[key] = valueToAppend
        }
        return result
    }
}

private extension Date {
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS+00:00"
        return formatter
    }
    
    var stringValue: String {
        return formatter.string(from: self)
    }
}
