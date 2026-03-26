//
//  AttributeDetailView.swift
//  Off
//

import SwiftUI
import Charts

struct AttributeDetailView: View {

    @Environment(AttributeManager.self) private var attributeManager

    let attribute: Attribute

    private var historyPoints: [AttributeHistoryPoint] {
        attributeManager.historyPoints(for: attribute)
    }

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    headerSection
                    currentStateSection

                    if !historyPoints.isEmpty {
                        chartSection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AttributeDetailView(attribute: .focus)
    }
    .withPreviewManagers()
}

// MARK: - Sections

private extension AttributeDetailView {

    var headerSection: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.offAccent.opacity(0.12))
                    .frame(width: 50, height: 50)

                Image(systemName: attribute.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
            }

            Text(attribute.label)
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.5)
        }
    }

    var currentStateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionEyebrow("Current state")
            
            VStack(alignment: .leading, spacing: 14) {
                stateDots(dotCount: attributeManager.dotCount(for: attribute), size: 13, spacing: 8)

                Text(attributeManager.stateLabel(for: attribute))
                    .font(.body)
                    .foregroundStyle(Color.offTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.offBackgroundSecondary.opacity(0.6))
            )
        }
    }

    var chartSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionEyebrow("Last 7 days")
            attributeChart
        }
    }

    var attributeChart: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("How your \(attribute.label) changed over the last 7 days")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 0) {
                    attributeChartPlot
                        .frame(height: 180)

                    HStack(spacing: 0) {
                        ForEach(historyPoints) { point in
                            Text(point.date, format: .dateTime.weekday(.abbreviated))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.offTextMuted)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 0) {
                    Text("High")
                    Spacer()
                    Text("Okay")
                    Spacer()
                    Text("Low")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.offTextMuted)
                .frame(width: 34, height: 180, alignment: .leading)
            }
            .padding(.horizontal, 2)
            .padding(.top, 14)
            .padding(.bottom, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.offBackgroundSecondary.opacity(0.6))
        )
    }

    var attributeChartPlot: some View {
        Chart {
            ForEach(historyPoints) { point in
                AreaMark(
                    x: .value("Day", point.date, unit: .day),
                    yStart: .value("Chart Floor", -5.0),
                    yEnd: .value("State", point.stateValue)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.offAccent.opacity(0.18),
                            Color.offAccent.opacity(0.05),
                            Color.offAccent.opacity(0.01)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            ForEach(historyPoints) { point in
                LineMark(
                    x: .value("Day", point.date, unit: .day),
                    y: .value("State", point.stateValue)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(Color.offAccent)
            }
        }
        .chartLegend(.hidden)
        .chartYScale(domain: -5.0...5.0)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(values: [-5.0, 0.0, 5.0]) { _ in
                AxisGridLine()
                    .foregroundStyle(Color.offStroke.opacity(0.2))
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.clear)
        }
    }

    func sectionEyebrow(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .heavy))
            .foregroundStyle(Color.offTextMuted)
            .tracking(1.4)
    }

    func stateDots(dotCount: Int, size: CGFloat, spacing: CGFloat) -> some View {
        HStack(spacing: spacing) {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(index < dotCount ? Color.offAccent : Color.offStroke.opacity(0.3))
                    .frame(width: size, height: size)
            }
        }
    }
}
