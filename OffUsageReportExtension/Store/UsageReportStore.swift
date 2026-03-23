//
//  UsageReportStore.swift
//  OffUsageReportExtension
//

import DeviceActivity
import Foundation
import ManagedSettings
import _DeviceActivity_SwiftUI

struct UsageReportRawSnapshot {
    let dailyDurations: [Date: TimeInterval]
    let dailyChecks: [Date: Int]
    let dailyAppDurations: [Date: [String: TimeInterval]]
    let hasApplicationUsage: Bool
}

protocol UsageReportStore {
    func loadRawSnapshot(from data: DeviceActivityResults<DeviceActivityData>) async throws -> UsageReportRawSnapshot
}

final class DeviceActivityUsageReportStore: UsageReportStore {

    func loadRawSnapshot(from data: DeviceActivityResults<DeviceActivityData>) async throws -> UsageReportRawSnapshot {
        let calendar = Calendar.current

        var dailyDurations: [Date: TimeInterval] = [:]
        var dailyChecks: [Date: Int] = [:]
        var dailyAppDurations: [Date: [String: TimeInterval]] = [:]
        var hasApplicationUsage = false

        for await deviceData in data {
            for await segment in deviceData.activitySegments {
                let day = calendar.startOfDay(for: segment.dateInterval.start)
                var dayBreakdown = dailyAppDurations[day, default: [:]]
                var segmentApplicationDuration: TimeInterval = 0
                var segmentApplicationChecks: Int = 0
                var segmentCategoryDuration: TimeInterval = 0
                var hasApplicationRowsInSegment = false

                for await category in segment.categories {
                    segmentCategoryDuration += category.totalActivityDuration

                    for await application in category.applications {
                        hasApplicationUsage = true
                        hasApplicationRowsInSegment = true

                        let appName = appLabel(for: application.application)
                        let appDuration = application.totalActivityDuration
                        segmentApplicationDuration += appDuration
                        segmentApplicationChecks += application.numberOfPickups
                        dayBreakdown[appName, default: 0] += appDuration
                    }
                }

                if hasApplicationRowsInSegment {
                    dailyDurations[day, default: 0] += segmentApplicationDuration
                    dailyChecks[day, default: 0] += segmentApplicationChecks
                } else {
                    dailyDurations[day, default: 0] += segmentCategoryDuration
                }

                if !dayBreakdown.isEmpty {
                    dailyAppDurations[day] = dayBreakdown
                }
            }
        }

        return UsageReportRawSnapshot(
            dailyDurations: dailyDurations,
            dailyChecks: dailyChecks,
            dailyAppDurations: dailyAppDurations,
            hasApplicationUsage: hasApplicationUsage
        )
    }
}

private extension DeviceActivityUsageReportStore {

    func appLabel(for application: Application) -> String {
        application.localizedDisplayName ?? application.bundleIdentifier ?? "App"
    }
}
