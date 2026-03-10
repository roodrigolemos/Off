//
//  PlanTimeWindowRules.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation

enum PlanTimeWindowRules {
    static let defaultWindow = TimeWindowValue(
        startHour: 9,
        startMinute: 0,
        endHour: 17,
        endMinute: 0
    )

    static func normalized(timeBoundary: TimeBoundary, timeWindows: [TimeWindowValue]) -> [TimeWindowValue] {
        switch timeBoundary {
        case .always:
            return []
        case .duringWindows:
            let firstWindow = timeWindows.first ?? defaultWindow
            return [clamped(window: firstWindow)]
        }
    }

    static func hasValidScheduledWindow(timeBoundary: TimeBoundary, timeWindows: [TimeWindowValue]) -> Bool {
        guard timeBoundary == .duringWindows else { return true }
        guard let window = normalized(timeBoundary: timeBoundary, timeWindows: timeWindows).first else { return false }
        return isValid(window: window)
    }

    static func isValid(window: TimeWindowValue) -> Bool {
        endMinutes(of: window) > startMinutes(of: window)
    }

    private static func clamped(window: TimeWindowValue) -> TimeWindowValue {
        TimeWindowValue(
            startHour: window.startHour.clamped(to: 0...23),
            startMinute: window.startMinute.clamped(to: 0...59),
            endHour: window.endHour.clamped(to: 0...23),
            endMinute: window.endMinute.clamped(to: 0...59)
        )
    }

    private static func startMinutes(of window: TimeWindowValue) -> Int {
        (window.startHour * 60) + window.startMinute
    }

    private static func endMinutes(of window: TimeWindowValue) -> Int {
        (window.endHour * 60) + window.endMinute
    }
}
