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
            switch currentDate {
            case ..<sunDayStart:
                backgroundColors[0]
            case sunDayStart..<morningEnd:
                backgroundColors[1]
            case morningEnd..<eveningStart:
                backgroundColors[2]
            case eveningStart...sunDayEnd:
                backgroundColors[3]
            default:
                backgroundColors[4]
            }
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

        var morningEnd: Date {
            calendar.date(bySettingHour: 11, minute: 0, second: 0, of: currentDate) ?? .now
        }

        var eveningStart: Date {
            calendar.date(bySettingHour: 16, minute: 0, second: 0, of: currentDate) ?? .now
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
                LinearGradient(colors: [Color(hex: "05060B"), Color(hex: "072831"), Color(hex: "074F5B")], startPoint: .top, endPoint: .bottom),
                LinearGradient(colors: [Color(hex: "101E3C"), Color(hex: "745C93"), Color(hex: "FDB56D")], startPoint: .top, endPoint: .bottom),
                LinearGradient(colors: [Color(hex: "1F78AF"), Color(hex: "62C6FD"), Color(hex: "C4F3FA")], startPoint: .top, endPoint: .bottom),
                LinearGradient(colors: [Color(hex: "6B3E67"), Color(hex: "FE8771"), Color(hex: "FFBB78")], startPoint: .top, endPoint: .bottom),
                LinearGradient(colors: [Color(hex: "0D0D1F"), Color(hex: "003366"), Color(hex: "001848")], startPoint: .top, endPoint: .bottom),
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
