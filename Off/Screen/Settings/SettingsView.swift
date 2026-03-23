//
//  SettingsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI
import StoreKit

struct SettingsView: View {

    @Environment(PlanManager.self) var planManager
    @Environment(ScreenTimeManager.self) var screenTimeManager
    @Environment(\.requestReview) private var requestReview

    @State private var showPlanDetails: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.offBackgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        currentPlanSection
                        accessSection
                        notificationsSection
                        supportSection
                        legalSection
                    }
                    .padding(.bottom, 48)
                }
                .scrollIndicators(.hidden)
            }
            .navigationDestination(isPresented: $showPlanDetails) {
                PlanDetailsView()
            }
        }
    }
}

private extension SettingsView {

    var headerSection: some View {
        Text("Settings")
            .font(.system(size: 38, weight: .heavy))
            .foregroundStyle(Color.offTextPrimary)
            .tracking(-0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)
    }

    var currentPlanSection: some View {
        settingsSection(title: "CURRENT PLAN", bottomPadding: 28) {
            Button {
                showPlanDetails = true
            } label: {
                currentPlanCard
            }
            .buttonStyle(.plain)
        }
    }

    var accessSection: some View {
        settingsSection(title: "ACCESS") {
            settingsRow(
                icon: "hourglass.badge.shield.half.filled",
                title: "Screen Time Access",
                subtitle: "Required for app limits and usage",
                iconColor: accessBadgeColor,
                action: {}
            ) {
                HStack(spacing: 10) {
                    statusBadge(title: accessStatusTitle, tint: accessBadgeColor)
                    rowChevron
                }
            }
        }
    }

    var notificationsSection: some View {
        settingsSection(title: "NOTIFICATIONS") {
            settingsRow(
                icon: "bell.badge",
                title: "Notifications",
                subtitle: "Manage reminders and alerts",
                action: {}
            ) {
                rowChevron
            }
        }
    }

    var supportSection: some View {
        settingsSection(title: "SUPPORT") {
            VStack(spacing: 14) {
                settingsRow(
                    icon: "bubble.left.and.text.bubble.right",
                    title: "Contact Support",
                    subtitle: "Get help with Off",
                    action: {}
                ) {
                    rowChevron
                }

                settingsRow(
                    icon: "star",
                    title: "Rate the App",
                    subtitle: "Leave a review on the App Store",
                    action: {
                        requestReview()
                    }
                ) {
                    rowChevron
                }

                settingsRow(
                    icon: "square.and.arrow.up",
                    title: "Share App",
                    subtitle: "Tell someone about Off",
                    action: {}
                ) {
                    rowChevron
                }
            }
        }
    }

    var legalSection: some View {
        settingsSection(title: "LEGAL") {
            VStack(spacing: 14) {
                settingsRow(
                    icon: "hand.raised",
                    title: "Privacy Policy",
                    subtitle: "How your data is handled",
                    action: {}
                ) {
                    rowChevron
                }

                settingsRow(
                    icon: "doc.text",
                    title: "Terms of Use",
                    subtitle: "Read the product terms",
                    action: {}
                ) {
                    rowChevron
                }
            }
        }
    }
}

private extension SettingsView {

    func settingsSection<Content: View>(
        title: String,
        bottomPadding: CGFloat = 36,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            content()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, bottomPadding)
    }

    var currentPlanCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccentSoft.opacity(0.18),
                            Color.offAccent.opacity(0.03),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 16) {
                rowLeadingIcon(
                    icon: planManager.activePlan?.displayIcon ?? PlanVisuals.defaultIcon,
                    color: .offAccent,
                    size: 46
                )

                VStack(alignment: .leading, spacing: 5) {
                    Text(planManager.activePlan?.displayName ?? "No Plan")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text(planSummaryText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 12)

                ZStack {
                    Circle()
                        .fill(Color.offAccent.opacity(0.08))
                        .frame(width: 42, height: 42)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.offAccent)
                }
            }
            .padding(24)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    func settingsRow<Accessory: View>(
        icon: String,
        title: String,
        subtitle: String,
        iconColor: Color = .offAccent,
        action: @escaping () -> Void,
        @ViewBuilder accessory: () -> Accessory
    ) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                HStack(spacing: 14) {
                    rowLeadingIcon(icon: icon, color: iconColor, size: 38)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer(minLength: 12)

                    accessory()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.offStroke, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    func rowLeadingIcon(icon: String, color: Color, size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: size, height: size)

            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(color)
        }
    }

    func statusBadge(title: String, tint: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.opacity(0.12))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(tint.opacity(0.2), lineWidth: 1)
            )
    }

    var rowChevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.offTextMuted)
    }
}

private extension SettingsView {

    var planSummaryText: String {
        guard let plan = planManager.activePlan else {
            return "View or set up your plan"
        }

        return [
            daysDescription(plan.days),
            "\(plan.dailyAppLimit) min/day"
        ]
        .filter { !$0.isEmpty }
        .joined(separator: " · ")
    }

    var accessStatusTitle: String {
        screenTimeManager.isAuthorized ? "Connected" : "Not Connected"
    }

    var accessBadgeColor: Color {
        screenTimeManager.isAuthorized ? .offAccent : .offWarn
    }

    func daysDescription(_ days: DaysOfWeek) -> String {
        if days == .everyday { return "Everyday" }
        if days == .weekdays { return "Weekdays" }
        if days == .weekends { return "Weekends" }

        let ordered: [(DaysOfWeek, String)] = [
            (.monday, "Mon"),
            (.tuesday, "Tue"),
            (.wednesday, "Wed"),
            (.thursday, "Thu"),
            (.friday, "Fri"),
            (.saturday, "Sat"),
            (.sunday, "Sun")
        ]

        return ordered
            .compactMap { days.contains($0.0) ? $0.1 : nil }
            .joined(separator: ", ")
    }
}

#Preview {
    SettingsView()
        .withPreviewManagers()
}
