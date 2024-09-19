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
        @Published var selectedTimeIndex: Int?

        var currentTime: String {
            times[selectedTimeIndex ?? 0]
        }

        var sunAngle: Angle {
            guard sunDayStart <= currentDate else {
                return .degrees(180)
            }
            guard currentDate <= sunDayEnd else {
                return .degrees(540)
            }

            let totalTime = sunDayEnd.timeIntervalSince(sunDayStart)
            let timePassed = currentDate.timeIntervalSince(sunDayStart)
            let percentage = timePassed / totalTime

            return .degrees(270 + percentage * 180)
        }

        var moonAngle: Angle {
            if sunDayStart <= currentDate && currentDate <= sunDayEnd {
                return .degrees(180)
            }
            if currentDate < sunDayStart {
                let totalTime = sunDayStart.timeIntervalSince(firstMidnight)
                let timePassed = currentDate.timeIntervalSince(firstMidnight)
                let percentage = timePassed / totalTime

                return .degrees(-90 + percentage * 180)
            } else {
                let totalTime = secondMidnight.timeIntervalSince(sunDayEnd)
                let timePassed = currentDate.timeIntervalSince(sunDayEnd)
                let percentage = timePassed / totalTime

                return .degrees(270 + percentage * 180)
            }
        }

        var backgroundColor: LinearGradient {
            sunDayStart <= currentDate && currentDate <= sunDayEnd ? backgroundColors[1] : backgroundColors[0]
        }

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

        var currentDate: Date {
            dateFormatter.date(from: currentTime) ?? .now
        }

        var sunDayStart: Date {
            calendar.date(bySettingHour: 4, minute: 0, second: 0, of: currentDate) ?? .now
        }

        var sunDayEnd: Date {
            calendar.date(bySettingHour: 22, minute: 0, second: 0, of: currentDate) ?? .now
        }

        var firstMidnight: Date {
            calendar.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate) ?? .now
        }

        var secondMidnight: Date {
            calendar.date(byAdding: .day, value: 1, to: firstMidnight) ?? .now
        }

        private var backgroundColors: [LinearGradient] {
            [
                LinearGradient(colors: [Color(hex: "000033"), Color(hex: "000066"), Color(hex: "191970")], startPoint: .top, endPoint: .bottom),
                LinearGradient(colors: [Color(hex: "FF4500"), Color(hex: "FFA07A"), Color(hex: "FFD700")], startPoint: .top, endPoint: .bottom),

            ]
        }

        // MARK: - Inits

        init() {
            initialiseTimes()
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

