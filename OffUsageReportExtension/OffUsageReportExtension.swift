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
            hasData: rawData.hasData,
            items: rawData.items.sorted {
                if $0.duration == $1.duration {
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }

                return $0.duration > $1.duration
            }
        )
    }

    func loadRawData(from data: DeviceActivityResults<DeviceActivityData>) async -> UsageReportRaw {
        let calendar = Calendar.current
        let today = Date()

        var totalDurationToday: TimeInterval = 0
        var hasUsageRows = false
        var itemsByID: [String: UsageItemUsage] = [:]

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
                        accumulate(
                            id: applicationID(for: application.application),
                            name: applicationName(for: application.application),
                            kind: .app,
                            duration: application.totalActivityDuration,
                            into: &itemsByID
                        )
                    }

                    for await webDomain in category.webDomains {
                        segmentDuration += webDomain.totalActivityDuration
                        hasChildRows = true
                        hasUsageRows = true
                        accumulate(
                            id: webDomainID(for: webDomain.webDomain),
                            name: webDomainName(for: webDomain.webDomain),
                            kind: .webDomain,
                            duration: webDomain.totalActivityDuration,
                            into: &itemsByID
                        )
                    }

                    if !hasChildRows {
                        segmentDuration += category.totalActivityDuration

                        if category.totalActivityDuration > 0 {
                            hasUsageRows = true
                            accumulate(
                                id: categoryID(for: category.category),
                                name: categoryName(for: category.category),
                                kind: .category,
                                duration: category.totalActivityDuration,
                                into: &itemsByID
                            )
                        }
                    }
                }

                totalDurationToday += segmentDuration
            }
        }

        return UsageReportRaw(
            totalDurationToday: totalDurationToday,
            hasData: hasUsageRows || totalDurationToday > 0,
            items: Array(itemsByID.values)
        )
    }

    func accumulate(
        id: String,
        name: String,
        kind: UsageItemKind,
        duration: TimeInterval,
        into itemsByID: inout [String: UsageItemUsage]
    ) {
        guard duration > 0 else { return }

        if var existing = itemsByID[id] {
            existing.duration += duration
            itemsByID[id] = existing
        } else {
            itemsByID[id] = UsageItemUsage(id: id, name: name, duration: duration, kind: kind)
        }
    }

    func applicationID(for application: Application) -> String {
        if let bundleIdentifier = application.bundleIdentifier {
            return "app:\(bundleIdentifier)"
        }

        if let token = application.token {
            return "app:\(String(describing: token))"
        }

        return "app:\(applicationName(for: application))"
    }

    func applicationName(for application: Application) -> String {
        application.localizedDisplayName ?? application.bundleIdentifier ?? "App"
    }

    func webDomainID(for webDomain: WebDomain) -> String {
        if let domain = webDomain.domain {
            return "web:\(domain)"
        }

        if let token = webDomain.token {
            return "web:\(String(describing: token))"
        }

        return "web:\(webDomainName(for: webDomain))"
    }

    func webDomainName(for webDomain: WebDomain) -> String {
        webDomain.domain ?? "Website"
    }

    func categoryID(for category: ActivityCategory) -> String {
        if let token = category.token {
            return "category:\(String(describing: token))"
        }

        return "category:\(categoryName(for: category))"
    }

    func categoryName(for category: ActivityCategory) -> String {
        category.localizedDisplayName ?? "Category"
    }
}

struct UsageReportRaw {
    let totalDurationToday: TimeInterval
    let hasData: Bool
    let items: [UsageItemUsage]
}

struct UsageItemUsage: Identifiable {
    let id: String
    let name: String
    var duration: TimeInterval
    let kind: UsageItemKind
}

enum UsageItemKind {
    case app
    case webDomain
    case category

    var label: String {
        switch self {
        case .app:
            return "APP"
        case .webDomain:
            return "WEBSITE"
        case .category:
            return "CATEGORY"
        }
    }
}

struct UsageData {

    let totalDurationToday: TimeInterval
    let hasData: Bool
    let items: [UsageItemUsage]

    var formattedDuration: String {
        format(duration: totalDurationToday)
    }

    var statusCopy: String {
        hasData
        ? "Across your current Off selection."
        : "No usage yet today for your current selection."
    }

    func format(duration: TimeInterval) -> String {
        if duration > 0, duration < 60 {
            return "<1m"
        }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = duration >= 3600 ? [.hour, .minute] : [.minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2

        return formatter.string(from: duration) ?? "0m"
    }
}

@MainActor
struct UsageActivityView: View {

    let usageData: UsageData

    var body: some View {
        VStack(spacing: 16) {
            totalUsageCard
            usageByItemCard
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension UsageActivityView {

    var totalUsageCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            cardEyebrow("TODAY")

            HStack(alignment: .center, spacing: 16) {
                cardIcon("hourglass.bottomhalf.filled")

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
        .modifier(UsageReportCardStyle())
    }

    var usageByItemCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            cardEyebrow("BY ITEM")

            Text("Usage per selected item")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)

            if usageData.items.isEmpty {
                Text("No itemized usage yet today.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.secondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(usageData.items.enumerated()), id: \.element.id) { index, item in
                        itemRow(item)

                        if index < usageData.items.count - 1 {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
            }
        }
        .modifier(UsageReportCardStyle())
    }

    func itemRow(_ item: UsageItemUsage) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: iconName(for: item.kind))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)

                Text(item.kind.label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.1)
            }

            Spacer()

            Text(usageData.format(duration: item.duration))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.primary)
        }
        .padding(.vertical, 14)
    }

    func iconName(for kind: UsageItemKind) -> String {
        switch kind {
        case .app:
            return "app.fill"
        case .webDomain:
            return "globe"
        case .category:
            return "square.grid.2x2.fill"
        }
    }

    func cardEyebrow(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .heavy))
            .foregroundStyle(Color.secondary)
            .tracking(1.6)
    }

    func cardIcon(_ name: String) -> some View {
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

            Image(systemName: name)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.accentColor)
        }
    }
}

private struct UsageReportCardStyle: ViewModifier {

    func body(content: Content) -> some View {
        content
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
