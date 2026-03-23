//
//  UsageReportContentView.swift
//  OffUsageReportExtension
//

import SwiftUI

struct UsageReportContentView: View {

    let configuration: UsageReportConfiguration

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerSection
                todayTotalCard
                todayAppsCard
                weekSummaryCard
                weekAppsCard
                comparisonCard
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 48)
        }
        .scrollIndicators(.hidden)
        .background(Color.offBackground)
    }
}

private extension UsageReportContentView {

    var headerSection: some View {
        Text("Usage")
            .font(.system(size: 38, weight: .heavy))
            .foregroundStyle(Color.offPrimaryText)
            .tracking(-0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 6)
    }

    var todayTotalCard: some View {
        UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 12) {
                Text("TODAY TOTAL")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.offMutedText)
                    .tracking(1.1)

                Text(UsageFormatters.durationText(from: configuration.today.totalDurationSeconds))
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(Color.offPrimaryText)

                Text(configuration.today.hasUsage ? "Selected apps used today." : "No tracked usage yet today.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.offSecondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var todayAppsCard: some View {
        UsageAppUsageListCardView(
            title: "TODAY BY APP",
            emptyText: configuration.today.hasUsage
                ? "No app-level usage available for today."
                : "No tracked app usage yet today.",
            apps: configuration.today.apps
        )
    }

    var weekSummaryCard: some View {
        UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 16) {
                Text("THIS WEEK")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.offMutedText)
                    .tracking(1.1)

                VStack(alignment: .leading, spacing: 4) {
                    Text(UsageFormatters.durationText(from: configuration.week.averageDailyDurationSeconds))
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(Color.offPrimaryText)

                    Text(configuration.week.hasUsage
                        ? "Average daily usage this week"
                        : "No tracked usage yet this week")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offSecondaryText)
                }

                UsageWeekBarsView(dayTotals: configuration.week.dayTotals)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var weekAppsCard: some View {
        UsageAppUsageListCardView(
            title: "MOST USED THIS WEEK",
            emptyText: configuration.week.hasUsage
                ? "No app-level usage available for this week."
                : "No tracked app usage yet this week.",
            apps: configuration.week.apps
        )
    }

    var comparisonCard: some View {
        UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 12) {
                Text("WEEK OVER WEEK")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.offMutedText)
                    .tracking(1.1)

                if configuration.comparison.hasPreviousData {
                    Text(comparisonTitle)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(comparisonAccentColor)

                    Text(comparisonBody)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offSecondaryText)

                    Text("This week: \(UsageFormatters.durationText(from: configuration.comparison.currentPeriodDurationSeconds)) • Previous: \(UsageFormatters.durationText(from: configuration.comparison.previousPeriodDurationSeconds))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.offMutedText)
                } else {
                    Text("Not enough data yet")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(Color.offPrimaryText)

                    Text("We need more tracked days before we can compare this week with the previous one.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offSecondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var comparisonTitle: String {
        switch configuration.comparison.direction {
        case .higher:
            "Higher than last week"
        case .lower:
            "Lower than last week"
        case .same:
            "Same as last week"
        }
    }

    var comparisonBody: String {
        switch configuration.comparison.direction {
        case .higher:
            return "\(UsageFormatters.durationText(from: configuration.comparison.deltaDurationSeconds)) more vs the same point last week."
        case .lower:
            return "\(UsageFormatters.durationText(from: configuration.comparison.deltaDurationSeconds)) less vs the same point last week."
        case .same:
            return "No time difference versus the same point last week."
        }
    }

    var comparisonAccentColor: Color {
        switch configuration.comparison.direction {
        case .higher:
            Color.offWarningTone
        case .lower:
            Color.offSuccessTone
        case .same:
            Color.offPrimaryText
        }
    }
}

private struct UsageWeekBarsView: View {

    let dayTotals: [UsageDayBarSnapshot]

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(dayTotals) { day in
                VStack(spacing: 8) {
                    Spacer(minLength: 0)

                    ZStack(alignment: .bottom) {
                        Capsule()
                            .fill(Color.offTrackBackground)
                            .frame(width: 24, height: 108)

                        Capsule()
                            .fill(day.isToday ? Color.offAccent : Color.offAccent.opacity(0.55))
                            .frame(width: 24, height: barHeight(for: day))
                    }

                    Text(day.label)
                        .font(.system(size: 11, weight: day.isToday ? .bold : .semibold))
                        .foregroundStyle(day.isToday ? Color.offPrimaryText : Color.offSecondaryText)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 142, alignment: .bottom)
    }
}

private extension UsageWeekBarsView {

    func barHeight(for day: UsageDayBarSnapshot) -> CGFloat {
        let maxDuration = dayTotals.map(\.totalDurationSeconds).max() ?? 0
        guard day.totalDurationSeconds > 0 else { return 8 }
        guard maxDuration > 0 else { return 8 }

        let normalized = day.totalDurationSeconds / maxDuration
        return max(16, CGFloat(normalized) * 108)
    }
}

private struct UsageAppUsageListCardView: View {

    let title: String
    let emptyText: String
    let apps: [UsageAppUsageSnapshot]

    @State private var isExpanded = false

    var body: some View {
        UsageReportCardContainerView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.offMutedText)
                    .tracking(1.1)

                if apps.isEmpty {
                    Text(emptyText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offSecondaryText)
                } else {
                    VStack(spacing: 10) {
                        ForEach(visibleApps) { app in
                            HStack(spacing: 12) {
                                Text(app.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.offPrimaryText)
                                    .lineLimit(1)

                                Spacer()

                                Text(UsageFormatters.durationText(from: app.totalDurationSeconds))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.offSecondaryText)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                if apps.count > collapsedCount {
                    Button(isExpanded ? "Show less" : "Show more") {
                        isExpanded.toggle()
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private extension UsageAppUsageListCardView {

    var collapsedCount: Int { 5 }

    var visibleApps: [UsageAppUsageSnapshot] {
        if isExpanded {
            return apps
        }
        return Array(apps.prefix(collapsedCount))
    }
}

extension Color {
    static let offBackground = Color(
        red: 246.0 / 255.0,
        green: 244.0 / 255.0,
        blue: 239.0 / 255.0
    )
    static let offSurface = Color.white
    static let offPrimaryText = Color(red: 0.11, green: 0.13, blue: 0.16)
    static let offSecondaryText = Color(red: 0.38, green: 0.42, blue: 0.47)
    static let offMutedText = Color(red: 0.49, green: 0.53, blue: 0.58)
    static let offAccent = Color(
        red: 76.0 / 255.0,
        green: 122.0 / 255.0,
        blue: 138.0 / 255.0
    )
    static let offAccentSoft = Color(
        red: 230.0 / 255.0,
        green: 240.0 / 255.0,
        blue: 243.0 / 255.0
    )
    static let offSuccessTone = Color(red: 0.18, green: 0.64, blue: 0.38)
    static let offWarningTone = Color(red: 0.83, green: 0.54, blue: 0.16)
    static let offTileStroke = Color(
        red: 230.0 / 255.0,
        green: 225.0 / 255.0,
        blue: 217.0 / 255.0
    )
    static let offTrackBackground = Color.offAccentSoft
}
