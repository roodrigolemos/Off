//
//  WeeklyInsightDetailView.swift
//  Off
//


import SwiftUI

struct WeeklyInsightDetailView: View {

    @Environment(InsightManager.self) var insightManager
    @Environment(PlanManager.self) var planManager
    @Environment(CheckInManager.self) var checkInManager
    @Environment(UrgeManager.self) var urgeManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                titleSection
                headerSection

                if insightManager.isGenerating {
                    loadingSection
                } else if insightManager.error == .insufficientData {
                    insufficientDataSection
                } else if let insight = insightManager.currentInsight {
                    whatsHappeningSection(insight.whatsHappening)
                    whyThisHappensSection(insight.whyThisHappens)
                    whatToExpectSection(insight.whatToExpect)

                    if let pattern = insight.patternIdentified {
                        patternSection(pattern)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color.offBackgroundPrimary)
        .task {
            await insightManager.prepareInsightIfNeeded(
                plan: planManager.activePlan,
                checkIns: checkInManager.checkIns,
                interventions: urgeManager.interventions
            )
        }
    }
}

#Preview {
    WeeklyInsightDetailView()
        .withPreviewManagers()
}

// MARK: - Sections

private extension WeeklyInsightDetailView {

    var titleSection: some View {
        HStack {
            Text("Week \(insightManager.weeksSincePlanCreation(plan: planManager.activePlan)) Insight")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.offTextSecondary)
                    .frame(width: 32, height: 32)
                    .background(Color.offBackgroundSecondary)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.offAccent.opacity(0.12))
                        .frame(width: 32, height: 32)

                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.offAccent)
                }

                Text("WEEKLY INSIGHT")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.offAccent)
                    .tracking(1.2)
            }

            Text(headerDateText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(Color.offAccent)

            Text("Generating your insight...")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    var insufficientDataSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(Color.offTextMuted)

            Text("Not enough data yet")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)

            Text("You need at least 3 check-ins from last week to generate an insight.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.offTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
    }

    func whatsHappeningSection(_ content: String) -> some View {
        insightSection(
            icon: "eye.fill",
            title: "What's Happening",
            content: content,
            accentColor: Color.offAccent
        )
        .padding(.horizontal, 24)
    }

    func whyThisHappensSection(_ content: String) -> some View {
        insightSection(
            icon: "brain.head.profile",
            title: "Why This Happens",
            content: content,
            accentColor: Color(red: 0.6, green: 0.4, blue: 0.8)
        )
        .padding(.horizontal, 24)
    }

    func whatToExpectSection(_ content: String) -> some View {
        insightSection(
            icon: "arrow.forward.circle.fill",
            title: "What to Expect",
            content: content,
            accentColor: Color(red: 0.3, green: 0.7, blue: 0.5)
        )
        .padding(.horizontal, 24)
    }

    func patternSection(_ content: String) -> some View {
        insightSection(
            icon: "waveform.path.ecg",
            title: "Pattern Identified",
            content: content,
            accentColor: Color(red: 0.9, green: 0.6, blue: 0.3)
        )
        .padding(.horizontal, 24)
    }

    func insightSection(
        icon: String,
        title: String,
        content: String,
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(accentColor)
                }

                Text(title)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)
                    .tracking(0.3)
            }

            Text(content)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.offTextPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.offBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(accentColor.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Helpers

private extension WeeklyInsightDetailView {

    var headerDateText: String {
        if let insight = insightManager.currentInsight {
            return insight.generatedAt.formatted(.dateTime.weekday(.wide).month(.wide).day())
        }
        return Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}
