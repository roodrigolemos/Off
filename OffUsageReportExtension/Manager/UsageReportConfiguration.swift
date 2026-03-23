//
//  UsageReportConfiguration.swift
//  OffUsageReportExtension
//

import Foundation

struct UsageReportConfiguration {
    let today: UsageTodaySnapshot
    let week: UsageWeekSnapshot
    let comparison: UsageWeekComparisonSnapshot
}

struct UsageTodaySnapshot {
    let totalDurationSeconds: TimeInterval
    let apps: [UsageAppUsageSnapshot]

    var hasUsage: Bool {
        totalDurationSeconds > 0
    }
}

struct UsageWeekSnapshot {
    let averageDailyDurationSeconds: TimeInterval
    let dayTotals: [UsageDayBarSnapshot]
    let apps: [UsageAppUsageSnapshot]
    let elapsedDayCount: Int

    var hasUsage: Bool {
        dayTotals.contains { $0.totalDurationSeconds > 0 }
    }
}

struct UsageWeekComparisonSnapshot {
    let direction: UsageWeekComparisonDirection
    let deltaDurationSeconds: TimeInterval
    let currentPeriodDurationSeconds: TimeInterval
    let previousPeriodDurationSeconds: TimeInterval
    let hasPreviousData: Bool
}

enum UsageWeekComparisonDirection {
    case higher
    case lower
    case same
}

struct UsageAppUsageSnapshot: Identifiable {
    let id: String
    let name: String
    let totalDurationSeconds: TimeInterval
}

struct UsageDayBarSnapshot: Identifiable {
    let id: Date
    let date: Date
    let label: String
    let totalDurationSeconds: TimeInterval
    let isToday: Bool
}

extension UsageReportConfiguration {
    static let empty = UsageReportConfiguration(
        today: UsageTodaySnapshot(
            totalDurationSeconds: 0,
            apps: []
        ),
        week: UsageWeekSnapshot(
            averageDailyDurationSeconds: 0,
            dayTotals: [],
            apps: [],
            elapsedDayCount: 0
        ),
        comparison: UsageWeekComparisonSnapshot(
            direction: .same,
            deltaDurationSeconds: 0,
            currentPeriodDurationSeconds: 0,
            previousPeriodDurationSeconds: 0,
            hasPreviousData: false
        )
    )
}
