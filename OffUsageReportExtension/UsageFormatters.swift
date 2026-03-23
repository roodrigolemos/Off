//
//  UsageFormatters.swift
//  OffUsageReportExtension
//

import Foundation

enum UsageFormatters {

    static func durationText(from seconds: TimeInterval) -> String {
        let totalMinutes = max(0, Int(seconds.rounded() / 60.0))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }

    static func percentDeltaText(from value: Double) -> String {
        let percentage = Int((value * 100.0).rounded())
        if percentage > 0 {
            return "+\(percentage)%"
        }
        return "\(percentage)%"
    }

    static func weekdayLabel(for date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    static func shortWeekdayLabel(for date: Date, calendar: Calendar = .current) -> String {
        weekdayLabel(for: date, calendar: calendar).uppercased()
    }
}
