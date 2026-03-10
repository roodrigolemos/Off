//
//  Date+Helpers.swift
//  Off
//

import Foundation

extension Date {

    static func thisWeekMonday(now: Date = .now) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = calendar.startOfDay(for: now)
        return calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
    }

    static func lastWeekMonday(now: Date = .now) -> Date {
        let thisMonday = thisWeekMonday(now: now)
        return Calendar.current.date(byAdding: .day, value: -7, to: thisMonday) ?? thisMonday
    }
}
