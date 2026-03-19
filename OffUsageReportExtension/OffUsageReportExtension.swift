//
//  OffUsageReportExtension.swift
//  OffUsageReportExtension
//
//  Created by Rodrigo Lemos on 19/03/26.
//

import SwiftUI
import DeviceActivity
import ExtensionKit
import ManagedSettings

@main
struct OffUsageReportExtension: DeviceActivityReportExtension {
    
    var body: some DeviceActivityReportScene {
        UsageActivityReport { usageData in
            UsageActivityView(usageData: usageData)
        }
    }
}

struct UsageActivityReport: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context = .usageReport
    let content: (UsageData) -> UsageActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> UsageData {

    }
    
    func loadRawData(from data: DeviceActivityResults<DeviceActivityData>) async throws -> UsageReportRaw {
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

        return UsageReportRaw(
            dailyDurations: dailyDurations,
            dailyChecks: dailyChecks,
            dailyAppDurations: dailyAppDurations,
            hasApplicationUsage: hasApplicationUsage
        )
    }
    
    func appLabel(for application: Application) -> String {
        application.localizedDisplayName ?? application.bundleIdentifier ?? "App"
    }
}

struct UsageReportRaw {
    let dailyDurations: [Date: TimeInterval]
    let dailyChecks: [Date: Int]
    let dailyAppDurations: [Date: [String: TimeInterval]]
    let hasApplicationUsage: Bool
}

struct UsageData {
    
}

struct UsageActivityView: View {
    
    let usageData: UsageData
    
    var body: some View {
        
    }
}
