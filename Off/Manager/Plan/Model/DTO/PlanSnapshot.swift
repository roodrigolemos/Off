//
//  PlanSnapshot.swift
//  Off
//

import Foundation

struct PlanSnapshot: Equatable {

    let firstPlanCreatedAt: Date
    let createdAt: Date
    let name: String
    let timeBoundary: TimeBoundary
    let timeWindows: [TimeWindowValue]
    let days: DaysOfWeek
    let lightSupports: Set<LightSupport>

    // Full initializer
    init(
        firstPlanCreatedAt: Date? = nil,
        createdAt: Date,
        name: String,
        timeBoundary: TimeBoundary,
        timeWindows: [TimeWindowValue],
        days: DaysOfWeek,
        lightSupports: Set<LightSupport>
    ) {
        let normalizedWindows = PlanTimeWindowRules.normalized(timeBoundary: timeBoundary, timeWindows: timeWindows)
        self.firstPlanCreatedAt = firstPlanCreatedAt ?? createdAt
        self.createdAt = createdAt
        self.name = name
        self.timeBoundary = timeBoundary
        self.timeWindows = normalizedWindows
        self.days = days
        self.lightSupports = Set(lightSupports.filter { LightSupport.allCases.contains($0) })
    }

    var displayName: String {
        return name
    }

    var displayIcon: String {
        PlanVisuals.defaultIcon
    }

    var activeDays: Int {
        max(0, Calendar.current.dateComponents([.day], from: createdAt, to: .now).day ?? 0)
    }
}
