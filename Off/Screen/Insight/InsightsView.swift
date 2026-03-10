//
//  InsightsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI
import Charts

struct InsightsView: View {

    @Environment(AttributeManager.self) var attributeManager
    @Environment(StatsManager.self) var statsManager

    @State private var showArchive: Bool = false
    @State private var selectedMonthIndex: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.offBackgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        attributeTrendsSection
                        planAdherenceSection
                        urgePatternSection
                        weeklyFeedbackSection
                        checkInHistorySection
                    }
                    .padding(.bottom, 48)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

#Preview {
    InsightsView()
        .withPreviewManagers()
}

// MARK: - Sections

private extension InsightsView {

    var headerSection: some View {
        Text("Insights")
            .font(.system(size: 38, weight: .heavy))
            .foregroundStyle(Color.offTextPrimary)
            .tracking(-0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)
    }

    var attributeTrendsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("ATTRIBUTE TRENDS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            trendChartsGrid
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var planAdherenceSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("PLAN ADHERENCE")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            adherenceCalendarCard
            streakCardsRow
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var urgePatternSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("URGE PATTERNS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            urgePatternCard
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var weeklyFeedbackSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("FEEDBACKS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            weeklyFeedbackCard
            if showArchive {
                weeklyFeedbackArchive
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var checkInHistorySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("PREVIOUS WEEKS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            previousWeeksStack
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

}

// MARK: - Helper Views

private extension InsightsView {

    var trendChartsGrid: some View {
        let scores = attributeManager.scores

        return LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ], spacing: 14) {
            ForEach(Attribute.allCases, id: \.self) { attribute in
                trendChartCard(
                    attribute: attribute,
                    currentScore: scores?.scores[attribute] ?? 3.0,
                    momentum: scores?.momentum[attribute] ?? false
                )
            }
        }
    }

    func trendChartCard(attribute: Attribute, currentScore: Double, momentum: Bool) -> some View {
        let description = levelDescription(for: attribute, score: currentScore)

        return ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.offAccent.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: attribute.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.offAccent)
                    }

                    Spacer()

                    if momentum {
                        Text("Momentum")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(Color.offAccent)
                            .tracking(0.4)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.offAccent.opacity(0.12))
                            )
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(attribute.label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)

                    HStack(spacing: 4) {
                        scoreDots(score: currentScore)
                    }

                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.offTextMuted)
                        .padding(.top, 8)
                }
            }
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var adherenceCalendarCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(spacing: 16) {
                monthNavigationHeader
                adherenceDayLabels
                adherenceGrid
                adherenceStats
            }
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var monthNavigationHeader: some View {
        let monthCount = statsManager.adherenceMonths.count
        let selected = selectedAdherenceMonth
        let maxIndex = max(monthCount - 1, 0)

        return HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedMonthIndex = min(selectedMonthIndex + 1, maxIndex)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedMonthIndex < maxIndex
                        ? Color.offTextPrimary
                        : Color.offTextMuted.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(selectedMonthIndex >= maxIndex)

            Spacer()

            Text(selected.displayName.uppercased())
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.4)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedMonthIndex = max(selectedMonthIndex - 1, 0)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(selectedMonthIndex > 0
                        ? Color.offTextPrimary
                        : Color.offTextMuted.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(selectedMonthIndex == 0)
        }
        .padding(.bottom, 12)
    }

    var adherenceDayLabels: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { _, day in
                Text(day)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.offTextMuted)
                    .tracking(1.0)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    var adherenceGrid: some View {
        let monthData = selectedAdherenceMonth.cells
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            ForEach(monthData) { day in
                if day.state == .padding {
                    Color.clear
                        .frame(width: 28, height: 28)
                } else {
                    Circle()
                        .fill(adherenceFillColor(for: day.state))
                        .overlay {
                            Circle()
                                .stroke(adherenceStrokeColor(for: day.state), lineWidth: adherenceStrokeWidth(for: day.state))
                        }
                        .frame(width: 28, height: 28)
                }
            }
        }
    }

    var adherenceStats: some View {
        let month = selectedAdherenceMonth

        return HStack {
            Text("\(month.numerator)/\(month.denominator) plan days · \(month.percentage)%")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.offTextPrimary)
            Spacer()
        }
    }

    var streakCardsRow: some View {
        HStack(spacing: 14) {
            planAdherenceDaysCard
            currentStreakCard
            bestEverStreakCard
        }
    }

    var planAdherenceDaysCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccent.opacity(0.04),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.offAccent.opacity(0.15),
                                        Color.offAccent.opacity(0.05)
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 26, height: 26)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    Text("\(statsManager.streakMetrics.totalDaysFollowed)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)
                }

                Text("Days\nfollowed")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.offTextSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var currentStreakCard: some View {
        let streakInfo = statsManager.streakMetrics

        return ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccent.opacity(0.04),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.offAccent.opacity(0.15),
                                        Color.offAccent.opacity(0.05)
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 26, height: 26)

                        Image(systemName: "flame.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    Text("\(streakInfo.current)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)
                }

                Text("Current\nstreak")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.offTextSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var bestEverStreakCard: some View {
        let streakInfo = statsManager.streakMetrics

        return ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offTextPrimary.opacity(0.03),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.offAccent.opacity(0.15),
                                        Color.offAccent.opacity(0.05)
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 26, height: 26)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    Text("\(streakInfo.bestEver)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)
                }

                Text("Best\never")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.offTextSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
    
    var urgePatternCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 12) {
                Text("Urge Trend")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                urgeChart
                urgeInsightsText
            }
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var urgeChart: some View {
        Chart {
            ForEach(statsManager.urgeTrendPoints) { point in
                AreaMark(
                    x: .value("Day", point.dayIndex),
                    y: .value("Urge", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.offWarn.opacity(0.12),
                            Color.offWarn.opacity(0.03),
                            Color.offWarn.opacity(0.01)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            ForEach(statsManager.urgeTrendPoints) { point in
                LineMark(
                    x: .value("Day", point.dayIndex),
                    y: .value("Urge", point.value)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.0, lineCap: .round))
                .foregroundStyle(Color.offWarn)
            }
        }
        .chartXScale(domain: 0...29)
        .chartYScale(domain: 0...3)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(values: [0, 1, 2, 3]) { value in
                AxisValueLabel {
                    Text(urgeLabel(for: value.as(Int.self) ?? 0))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.offTextMuted.opacity(0.7))
                }
                AxisGridLine()
                    .foregroundStyle(Color.offStroke.opacity(0.15))
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.clear)
                .cornerRadius(12)
        }
        .padding(.vertical, 8)
        .frame(height: 140)
    }

    var urgeInsightsText: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(statsManager.urgeInsights.trendDirectionMessage)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.offTextMuted)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            if let urgeAdherenceMessage = statsManager.urgeInsights.urgeAdherenceMessage {
                Text(urgeAdherenceMessage)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.offTextMuted)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var weeklyFeedbackCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccentSoft.opacity(0.15),
                            Color.clear,
                            Color.offAccent.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.offAccent.opacity(0.12))
                            .frame(width: 28, height: 28)

                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.offAccent)
                    }

                    Text("THIS WEEK")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(Color.offAccent)
                        .tracking(1.4)
                }

                Text("Calm showed up more than low moments. You're building something real here.")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)
                    .lineSpacing(2)

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showArchive.toggle()
                    }
                } label: {
                    Text("View past weeks →")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.offAccent)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var weeklyFeedbackArchive: some View {
        VStack(spacing: 12) {
            archiveWeekCard(
                dateRange: "Jan 13 – Jan 19",
                insight: "You started noticing urges earlier — that's awareness growing."
            )
            archiveWeekCard(
                dateRange: "Jan 6 – Jan 12",
                insight: "Focus improved on days you followed the evening plan."
            )
            archiveWeekCard(
                dateRange: "Dec 30 – Jan 5",
                insight: "First full week of check-ins. Consistency is the foundation."
            )
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    func archiveWeekCard(dateRange: String, insight: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(alignment: .leading, spacing: 8) {
                Text(dateRange.uppercased())
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.offTextMuted)
                    .tracking(1.4)

                Text(insight)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var previousWeeksStack: some View {
        VStack(spacing: 12) {
            previousWeekRow(dateRange: "Jan 13 – Jan 19", checkIns: "5/7 check-ins")
            previousWeekRow(dateRange: "Jan 6 – Jan 12", checkIns: "6/7 check-ins")
            previousWeekRow(dateRange: "Dec 30 – Jan 5", checkIns: "4/7 check-ins")
        }
    }

    func previousWeekRow(dateRange: String, checkIns: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateRange)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text(checkIns)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.offTextMuted)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

}

// MARK: - Helpers

private extension InsightsView {

    func scoreDots(score: Double) -> some View {
        let normalized = max(1.0, min(5.0, score))
        let fullDots = Int(normalized.rounded(.down))
        let hasHalfDot = (normalized - Double(fullDots)) >= 0.5

        return HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                let fill: Double = if index < fullDots {
                    1.0
                } else if index == fullDots && hasHalfDot {
                    0.5
                } else {
                    0.0
                }

                Circle()
                    .fill(Color.offStroke.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .overlay(alignment: .leading) {
                        Circle()
                            .fill(Color.offAccent)
                            .frame(width: 8, height: 8)
                            .mask(
                                Rectangle()
                                    .frame(width: 8 * fill, height: 8, alignment: .leading)
                            )
                    }
            }
        }
    }

    func levelDescription(for attribute: Attribute, score: Double) -> String {
        let descriptions: [Attribute: [String]] = [
            .clarity: [
                "Overwhelmed, foggy mind",
                "Glimpses of clarity",
                "Noticeably clearer thinking",
                "Clear, focused thinking",
                "Effortless mental clarity"
            ],
            .focus: [
                "Scattered, fleeting attention",
                "Brief focus bursts",
                "Improving sustained attention",
                "Deep concentration ability",
                "Natural flow state"
            ],
            .energy: [
                "Drained, exhausted constantly",
                "Slightly more energy",
                "Stable energy levels",
                "Consistent daily vitality",
                "Energized and present"
            ],
            .drive: [
                "Lost, disconnected",
                "Fleeting direction glimpses",
                "Developing clearer path",
                "Connected to goals",
                "Strong, unwavering purpose"
            ],
            .control: [
                "Powerless against urges",
                "Inconsistent self-control",
                "Growing urge control",
                "Solid impulse management",
                "Full intentional control"
            ],
            .patience: [
                "Zero stillness tolerance",
                "Noticing boredom reactivity",
                "Building stillness tolerance",
                "Comfortable with waiting",
                "Deep inner patience"
            ]
        ]

        let index = Int(max(1.0, min(5.0, score)).rounded(.up)) - 1
        guard let levels = descriptions[attribute], levels.indices.contains(index) else {
            return ""
        }

        return levels[index]
    }

    func urgeLabel(for index: Int) -> String {
        switch index {
        case 0: return "None"
        case 1: return "Mild"
        case 2: return "Moderate"
        default: return "Strong"
        }
    }

    var selectedAdherenceMonth: AdherenceMonth {
        if statsManager.adherenceMonths.isEmpty {
            return AdherenceMonth(
                id: "fallback",
                displayName: Date.now.formatted(.dateTime.month(.wide).year()),
                cells: [],
                numerator: 0,
                denominator: 0,
                percentage: 0
            )
        }
        let monthCount = statsManager.adherenceMonths.count
        let index = min(max(selectedMonthIndex, 0), max(monthCount - 1, 0))
        return statsManager.adherenceMonths[index]
    }

    func adherenceFillColor(for state: AdherenceCellState) -> Color {
        switch state {
        case .committedFollowed: return Color.offAccent
        case .committedMissed: return Color.offWarn
        case .offFollowed: return Color.offAccent.opacity(0.16)
        case .offNeutral: return Color.offTextMuted.opacity(0.2)
        case .inactive: return Color.offBackgroundPrimary
        case .todayNeutral: return Color.offBackgroundSecondary
        case .padding: return .clear
        }
    }

    func adherenceStrokeColor(for state: AdherenceCellState) -> Color {
        switch state {
        case .offFollowed, .todayNeutral: return Color.offAccent
        case .inactive: return Color.offStroke
        case .padding, .committedFollowed, .committedMissed, .offNeutral: return .clear
        }
    }

    func adherenceStrokeWidth(for state: AdherenceCellState) -> CGFloat {
        switch state {
        case .offFollowed, .todayNeutral: return 1
        default: return 0
        }
    }

}
