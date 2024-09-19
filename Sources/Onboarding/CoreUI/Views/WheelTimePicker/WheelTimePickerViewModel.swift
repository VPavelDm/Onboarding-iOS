//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 19.09.24.
//

import SwiftUI

@available(iOS 17.0, *)
extension WheelTimePicker {

    @MainActor
    final class ViewModel: ObservableObject {

        // MARK: - Outputs

        @Published var times: [String] = []

        // MARK: - Properties

        private let calendar = Calendar.current

        private let dateFormatter: DateFormatter = {
            let locale = Locale.current

            let dateFormatter = DateFormatter()
            dateFormatter.locale = locale

            if locale.is24TimeFormat {
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
            } else {
                dateFormatter.dateFormat = "hh:mm\na"
            }

            return dateFormatter
        }()

        // MARK: - Inits

        init() {
            initialiseTimes()
        }

        // MARK: - Intents

        func sunAngle(selectedTimeIndex: Int?) -> Angle {
            guard let selectedTimeIndex else { return .degrees(180) }
            let time = times[selectedTimeIndex]
            guard let date = dateFormatter.date(from: time) else {
                return .degrees(180)
            }
            guard let dayTimeStart = calendar.date(bySettingHour: 4, minute: 0, second: 0, of: date) else {
                return .degrees(180)
            }
            guard let dayTimeEnd = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: date) else {
                return .degrees(180)
            }
            guard dayTimeStart < date else {
                return .degrees(180)
            }
            guard date < dayTimeEnd else {
                return .degrees(540)
            }

            let totalTime = dayTimeEnd.timeIntervalSince(dayTimeStart)

            let timePassed = date.timeIntervalSince(dayTimeStart)

            let percentage = (timePassed / totalTime)

            return .degrees(270 + percentage * 180)
        }

        func moonAngle(selectedTimeIndex: Int?) -> Angle {
            guard let selectedTimeIndex else { return .degrees(180) }
            let time = times[selectedTimeIndex]
            guard let date = dateFormatter.date(from: time) else {
                return .degrees(180)
            }
            guard let dayTimeStart = calendar.date(bySettingHour: 4, minute: 0, second: 0, of: date) else {
                return .degrees(180)
            }
            guard let dayTimeEnd = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: date) else {
                return .degrees(180)
            }
            guard let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date) else {
                return .degrees(180)
            }
            guard date < dayTimeStart || dayTimeEnd < date else {
                return .degrees(540)
            }

            if date < dayTimeStart {
                let totalTime = dayTimeStart.timeIntervalSince(midnight)
                let timePassed = date.timeIntervalSince(midnight)
                let percentage = timePassed / totalTime
                return .degrees(270 + percentage * 180)
            } else if let nextDayMidnight = calendar.date(byAdding: .day, value: 1, to: midnight) {
                let totalTime = nextDayMidnight.timeIntervalSince(dayTimeEnd)
                let timePassed = date.timeIntervalSince(dayTimeEnd)
                let percentage = timePassed / totalTime
                return .degrees(630 + percentage * 180)
            } else {
                return .degrees(180)
            }
        }

        // MARK: - Utils

        private func initialiseTimes() {
            var times: [String] = []

            let midnight = calendar.startOfDay(for: Date())

            for hour in 0..<24 {
                for minute in stride(from: 0, to: 60, by: 30) {
                    guard let time = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: midnight) else {
                        continue
                    }
                    let formattedTime = dateFormatter.string(from: time)
                    times.append(formattedTime)
                }
            }

            self.times = times
        }
    }
}

