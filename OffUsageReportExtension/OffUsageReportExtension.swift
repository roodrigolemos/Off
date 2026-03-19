//
//  OffUsageReportExtension.swift
//  OffUsageReportExtension
//
//  Created by Rodrigo Lemos on 19/03/26.
//

import SwiftUI
import DeviceActivity
import ExtensionKit

@MainActor
@main
struct OffUsageReportExtension: DeviceActivityReportExtension {

    var body: some DeviceActivityReportScene {
        UsageActivityReport { usageData in
            UsageActivityView(usageData: usageData)
        }
    }
}

@MainActor
struct UsageActivityReport: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context = .usageReport
    let content: (UsageData) -> UsageActivityView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> UsageData {
        let rawData = await loadRawData(from: data)

        return UsageData(
            totalDurationToday: rawData.totalDurationToday,
            hasData: rawData.hasData
        )
    }

    func loadRawData(from data: DeviceActivityResults<DeviceActivityData>) async -> UsageReportRaw {
        let calendar = Calendar.current
        let today = Date()

        var totalDurationToday: TimeInterval = 0
        var hasUsageRows = false

        for await deviceData in data {
            for await segment in deviceData.activitySegments {
                guard calendar.isDate(segment.dateInterval.start, inSameDayAs: today) else { continue }

                var segmentDuration: TimeInterval = 0

                for await category in segment.categories {
                    var hasChildRows = false

                    for await application in category.applications {
                        segmentDuration += application.totalActivityDuration
                        hasChildRows = true
                        hasUsageRows = true
                    }

                    for await webDomain in category.webDomains {
                        segmentDuration += webDomain.totalActivityDuration
                        hasChildRows = true
                        hasUsageRows = true
                    }

                    if !hasChildRows {
                        segmentDuration += category.totalActivityDuration

                        if category.totalActivityDuration > 0 {
                            hasUsageRows = true
                        }
                    }
                }

                totalDurationToday += segmentDuration
            }
        }

        return UsageReportRaw(
            totalDurationToday: totalDurationToday,
            hasData: hasUsageRows || totalDurationToday > 0
        )
    }
}

struct UsageReportRaw {
    let totalDurationToday: TimeInterval
    let hasData: Bool
}

struct UsageData {

    let totalDurationToday: TimeInterval
    let hasData: Bool

    var formattedDuration: String {
        if totalDurationToday > 0, totalDurationToday < 60 {
            return "<1m"
        }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = totalDurationToday >= 3600 ? [.hour, .minute] : [.minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2

        return formatter.string(from: totalDurationToday) ?? "0m"
    }

    var statusCopy: String {
        hasData
        ? "Across your current Off selection."
        : "No usage yet today for your current selection."
    }
}

@MainActor
struct UsageActivityView: View {

    let usageData: UsageData

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("TODAY")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.secondary)
                .tracking(1.6)

            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.accentColor.opacity(0.18),
                                    Color.accentColor.opacity(0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)

                    Image(systemName: "hourglass.bottomhalf.filled")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Total usage")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.primary)

                    Text(usageData.statusCopy)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.secondary)
                        .lineSpacing(2)
                }
            }

            Text(usageData.formattedDuration)
                .font(.system(size: 44, weight: .heavy))
                .foregroundStyle(Color.primary)
                .tracking(-1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 1)
        )
    }
}
