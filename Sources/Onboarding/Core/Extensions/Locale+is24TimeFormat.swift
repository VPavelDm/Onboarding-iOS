//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 19.09.24.
//

import Foundation

extension Locale {

    var is24TimeFormat: Bool {
        let formatter = DateFormatter()
        formatter.locale = self
        formatter.timeStyle = .short

        let testTime = formatter.string(from: Date(timeIntervalSince1970: 13 * 60 * 60))

        return !testTime.contains("AM") && !testTime.contains("PM")
    }
}
