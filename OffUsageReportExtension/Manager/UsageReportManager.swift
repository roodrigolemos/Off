//
//  UsageReportManager.swift
//  OffUsageReportExtension
//

import DeviceActivity
import Foundation
import _DeviceActivity_SwiftUI

enum UsageReportError: Error, LocalizedError {
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "Could not load usage report data."
        }
    }
}

final class UsageReportManager {

    private let store: UsageReportStore

    var error: UsageReportError?

    init(store: UsageReportStore) {
        self.store = store
    }

    func makeConfiguration(
        from data: DeviceActivityResults<DeviceActivityData>,
        now: Date = .now
    ) async -> UsageReportConfiguration {
        do {
            let raw = try await store.loadRawSnapshot(from: data)
            error = nil
            return buildConfiguration(from: raw, now: now)
        } catch {
            self.error = .loadFailed
            return .empty
        }
    }
}

private extension UsageReportManager {

    func buildConfiguration(from raw: UsageReportRawSnapshot, now: Date) -> UsageReportConfiguration {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let currentWeekInterval = calendar.dateInterval(of: .weekOfYear, for: today) ?? DateInterval(start: today, duration: 7 * 24 * 60 * 60)
        let currentWeekDays = weekDates(for: currentWeekInterval, calendar: calendar)
        let elapsedCurrentWeekDays = currentWeekDays.filter { $0 <= today }

        let previousWeekAnchor = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        let previousWeekInterval = calendar.dateInterval(of: .weekOfYear, for: previousWeekAnchor) ?? currentWeekInterval
        let previousWeekDays = Array(weekDates(for: previousWeekInterval, calendar: calendar).prefix(elapsedCurrentWeekDays.count))

        let todayApps = appUsageRows(from: raw.dailyAppDurations[today] ?? [:])
        let currentWeekApps = appUsageRows(from: totalApps(for: elapsedCurrentWeekDays, dailyAppDurations: raw.dailyAppDurations))

        let todaySnapshot = UsageTodaySnapshot(
            totalDurationSeconds: raw.dailyDurations[today, default: 0],
            apps: todayApps
        )

        let weekDayTotals = currentWeekDays.map { day in
            UsageDayBarSnapshot(
                id: day,
                date: day,
                label: UsageFormatters.shortWeekdayLabel(for: day, calendar: calendar),
                totalDurationSeconds: raw.dailyDurations[day, default: 0],
                isToday: calendar.isDate(day, inSameDayAs: today)
            )
        }

        let currentWeekTotal = totalDuration(for: elapsedCurrentWeekDays, dailyDurations: raw.dailyDurations)
        let previousWeekTotal = totalDuration(for: previousWeekDays, dailyDurations: raw.dailyDurations)
        let elapsedDayCount = max(elapsedCurrentWeekDays.count, 1)

        let weekSnapshot = UsageWeekSnapshot(
            averageDailyDurationSeconds: currentWeekTotal / Double(elapsedDayCount),
            dayTotals: weekDayTotals,
            apps: currentWeekApps,
            elapsedDayCount: elapsedCurrentWeekDays.count
        )

        let comparison = makeComparisonSnapshot(
            currentWeekTotal: currentWeekTotal,
            previousWeekTotal: previousWeekTotal,
            previousWeekDays: previousWeekDays
        )

        return UsageReportConfiguration(
            today: todaySnapshot,
            week: weekSnapshot,
            comparison: comparison
        )
    }

    func makeComparisonSnapshot(
        currentWeekTotal: TimeInterval,
        previousWeekTotal: TimeInterval,
        previousWeekDays: [Date]
    ) -> UsageWeekComparisonSnapshot {
        let delta = currentWeekTotal - previousWeekTotal
        let hasPreviousData = !previousWeekDays.isEmpty
        let direction: UsageWeekComparisonDirection

        if delta > 0 {
            direction = .higher
        } else if delta < 0 {
            direction = .lower
        } else {
            direction = .same
        }

        return UsageWeekComparisonSnapshot(
            direction: direction,
            deltaDurationSeconds: abs(delta),
            currentPeriodDurationSeconds: currentWeekTotal,
            previousPeriodDurationSeconds: previousWeekTotal,
            hasPreviousData: hasPreviousData
        )
    }

    func weekDates(for interval: DateInterval, calendar: Calendar) -> [Date] {
        (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: interval.start).map {
                calendar.startOfDay(for: $0)
            }
        }
    }

    func totalApps(
        for days: [Date],
        dailyAppDurations: [Date: [String: TimeInterval]]
    ) -> [String: TimeInterval] {
        var totals: [String: TimeInterval] = [:]

        for day in days {
            for (name, duration) in dailyAppDurations[day] ?? [:] {
                totals[name, default: 0] += duration
            }
        }

        return totals
    }

    func appUsageRows(from totals: [String: TimeInterval]) -> [UsageAppUsageSnapshot] {
        totals
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending
                }
                return lhs.value > rhs.value
            }
            .map { item in
                UsageAppUsageSnapshot(
                    id: item.key,
                    name: item.key,
                    totalDurationSeconds: item.value
                )
            }
    }

    func totalDuration(for days: [Date], dailyDurations: [Date: TimeInterval]) -> TimeInterval {
        days.reduce(0) { partialResult, day in
            partialResult + dailyDurations[day, default: 0]
        }
    }
}
