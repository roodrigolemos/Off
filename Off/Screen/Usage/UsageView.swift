//
//  UsageView.swift
//  Off
//
//  Created by Rodrigo Lemos on 19/03/26.
//

import SwiftUI
import DeviceActivity
import FamilyControls

struct UsageView: View {

    @Environment(ScreenTimeManager.self) private var screenTimeManager
    @Environment(UsageManager.self) private var usageManager

    @State private var activitySelection = FamilyActivitySelection()
    @State private var hasLoadedInitialState = false
    @State private var showActivityPicker = false
    @State private var isRequestingAuthorization = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.offBackgroundPrimary.ignoresSafeArea()
                screenContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .familyActivityPicker(isPresented: $showActivityPicker, selection: $activitySelection)
            .onAppear {
                guard !hasLoadedInitialState else { return }
                hasLoadedInitialState = true
                activitySelection = screenTimeManager.selectedActivities
            }
            .onChange(of: activitySelection) { _, _ in
                guard showActivityPicker else { return }
                screenTimeManager.updateSelection(activitySelection)
            }
            .alert(
                "Error",
                isPresented: .init(
                    get: { screenTimeManager.error != nil },
                    set: { if !$0 { screenTimeManager.error = nil } }
                ),
                actions: {
                    Button("OK") { screenTimeManager.error = nil }
                },
                message: {
                    Text(screenTimeManager.error?.localizedDescription ?? "")
                }
            )
        }
    }
}

private extension UsageView {

    @ViewBuilder
    var screenContent: some View {
        switch usageManager.snapshot.state {
        case .usageEnabled:
            DeviceActivityReport(.usageReport, filter: usageFilter)
                .id(screenTimeManager.selectionDigest)
        case .requiredScreenTimePermission, .requiredSelection:
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    headerSection
                    setupCard
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
    }

    var headerSection: some View {
        Text("Usage")
            .font(.system(size: 38, weight: .heavy))
            .foregroundStyle(Color.offTextPrimary)
            .tracking(-0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 6)
    }

    var setupCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(cardEyebrow)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.2)

            VStack(alignment: .leading, spacing: 12) {
                Text(cardTitle)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)

                Text(cardBody)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .lineSpacing(3)
            }

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: cardIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(cardHintTitle)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text(cardHintBody)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.offAccentSoft)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.offAccent.opacity(0.22), lineWidth: 1)
            )

            Button {
                handlePrimaryAction()
            } label: {
                HStack(spacing: 10) {
                    if isRequestingAuthorization {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(primaryButtonTitle)
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.offAccent, Color.offAccent.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .foregroundStyle(.white)
            }
            .disabled(isRequestingAuthorization)
            .opacity(isRequestingAuthorization ? 0.85 : 1)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var usageFilter: DeviceActivityFilter {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: today)
        let previousWeekAnchor = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        let previousWeek = calendar.dateInterval(of: .weekOfYear, for: previousWeekAnchor)
        let start = previousWeek?.start ?? currentWeek?.start ?? today
        let interval = DateInterval(start: start, end: .now)

        return DeviceActivityFilter(
            segment: .daily(during: interval),
            applications: screenTimeManager.selectedActivities.applicationTokens,
            categories: screenTimeManager.selectedActivities.categoryTokens,
            webDomains: screenTimeManager.selectedActivities.webDomainTokens
        )
    }

    var cardEyebrow: String {
        switch usageManager.snapshot.state {
        case .requiredScreenTimePermission:
            "SCREEN TIME ACCESS"
        case .requiredSelection:
            "TRACKING SETUP"
        case .usageEnabled:
            "USAGE"
        }
    }

    var cardTitle: String {
        switch usageManager.snapshot.state {
        case .requiredScreenTimePermission:
            "Allow Screen Time to unlock your dashboard"
        case .requiredSelection:
            "Choose what Off should track"
        case .usageEnabled:
            "Usage"
        }
    }

    var cardBody: String {
        switch usageManager.snapshot.state {
        case .requiredScreenTimePermission:
            "Off needs Screen Time permission before it can read usage data or show your dashboard."
        case .requiredSelection:
            "Select the apps, categories, or websites you want Off to include in the Usage tab."
        case .usageEnabled:
            ""
        }
    }

    var cardHintTitle: String {
        switch usageManager.snapshot.state {
        case .requiredScreenTimePermission:
            "Required for usage insights"
        case .requiredSelection:
            "At least one selection is required"
        case .usageEnabled:
            ""
        }
    }

    var cardHintBody: String {
        switch usageManager.snapshot.state {
        case .requiredScreenTimePermission:
            "iOS will ask for access once. After approval, Off can refresh this tab automatically."
        case .requiredSelection:
            "After you dismiss the picker, the dashboard will appear as soon as there is a valid selection."
        case .usageEnabled:
            ""
        }
    }

    var cardIcon: String {
        switch usageManager.snapshot.state {
        case .requiredScreenTimePermission:
            "hourglass.badge.shield.half.filled"
        case .requiredSelection:
            "apps.iphone.badge.plus"
        case .usageEnabled:
            "chart.bar.fill"
        }
    }

    var primaryButtonTitle: String {
        switch usageManager.snapshot.state {
        case .requiredScreenTimePermission:
            isRequestingAuthorization ? "Requesting access..." : "Allow Screen Time access"
        case .requiredSelection:
            "Choose apps"
        case .usageEnabled:
            "Open"
        }
    }

    func handlePrimaryAction() {
        switch usageManager.snapshot.state {
        case .requiredScreenTimePermission:
            Task {
                await requestAuthorization()
            }
        case .requiredSelection:
            activitySelection = screenTimeManager.selectedActivities
            showActivityPicker = true
        case .usageEnabled:
            break
        }
    }

    func requestAuthorization() async {
        guard !isRequestingAuthorization else { return }

        isRequestingAuthorization = true
        await screenTimeManager.requestAuthorization()
        isRequestingAuthorization = false
    }
}

#Preview {
    UsageView()
        .withPreviewManagers()
}
