//
//  UsageView.swift
//  Off
//
//  Created by Rodrigo Lemos on 19/03/26.
//

import SwiftUI
import DeviceActivity
import _DeviceActivity_SwiftUI
import FamilyControls

struct UsageView: View {

    @Environment(ScreenTimeManager.self) var screenTimeManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color.offBackgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection

                        if !screenTimeManager.isAuthorized {
                            permissionRequiredCard
                        } else if !screenTimeManager.hasSelectedActivity {
                            emptySelectionCard
                        } else {
                            usageReportSection
                        }
                    }
                    .padding(.bottom, 48)
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            screenTimeManager.loadSelection()

            Task {
                await screenTimeManager.checkAuthorization()
            }
        }
    }
}

#Preview {
    UsageView()
        .withPreviewManagers()
}

private extension UsageView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Usage")
                .font(.system(size: 38, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.5)

            Text("Today for the apps, categories, and websites currently selected in Off.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    var usageReportSection: some View {
        DeviceActivityReport(.usageReport, filter: todayFilter)
            .frame(maxWidth: .infinity, minHeight: 460, alignment: .topLeading)
            .padding(.horizontal, 24)
    }

    var permissionRequiredCard: some View {
        infoCard(
            title: "Screen Time access required",
            message: "Turn on Screen Time permission for Off to show your selected usage today."
        )
    }

    var emptySelectionCard: some View {
        infoCard(
            title: "No apps selected yet",
            message: "Choose at least one app, category, or website in Off before this tab can show your usage today."
        )
    }

    var todayFilter: DeviceActivityFilter {
        DeviceActivityFilter(
            segment: .hourly(during: todayInterval),
            users: .all,
            devices: .all,
            applications: screenTimeManager.selectedActivities.applicationTokens,
            categories: screenTimeManager.selectedActivities.categoryTokens,
            webDomains: screenTimeManager.selectedActivities.webDomainTokens
        )
    }

    var todayInterval: DateInterval {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let now = Date()
        let end = now > startOfDay ? now : startOfDay.addingTimeInterval(1)

        return DateInterval(start: startOfDay, end: end)
    }

    func infoCard(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.offAccent.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)

                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
}
