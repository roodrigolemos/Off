//
//  SettingsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct SettingsView: View {

    @Environment(PlanManager.self) var planManager

    @State private var eveningReminderOn: Bool = true
    @State private var weeklyFeedbackOn: Bool = true
    @State private var patternInsightsOn: Bool = false
    @State private var showPlanDetails: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.offBackgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        currentPlanSection
                        notificationsSection
                        accountDataSection
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
        VStack(alignment: .leading, spacing: 18) {
            Text("CURRENT PLAN")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            Button { showPlanDetails = true } label: {
                currentPlanCard
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("NOTIFICATIONS")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            notificationsCard
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var accountDataSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("ACCOUNT & DATA")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            VStack(spacing: 14) {
                accountActionRow(
                    icon: "square.and.arrow.up",
                    title: "Export Check-in History",
                    subtitle: "Download your data as CSV",
                    iconColor: Color.offAccent
                )

                accountActionRow(
                    icon: "creditcard",
                    title: "Manage Subscription",
                    subtitle: "View or change your plan",
                    iconColor: Color.offAccent
                )

                deleteDataButton
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }
}

private extension SettingsView {

    var currentPlanCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccentSoft.opacity(0.15),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 0) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.offAccent.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: planManager.activePlan?.displayIcon ?? PlanVisuals.defaultIcon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.offAccent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(planManager.activePlan?.displayName ?? "No Plan")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.offTextPrimary)

                        if let days = planManager.activePlan?.activeDays {
                            Text("Active for \(days) days")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.offTextSecondary)
                        }
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.offAccent.opacity(0.08))
                        .frame(width: 44, height: 44)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
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

    var notificationsCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Evening Check-in Reminder")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text("Daily reminder to check in")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $eveningReminderOn)
                        .tint(Color.offAccent)
                        .labelsHidden()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)

                Divider()
                    .background(Color.offStroke)
                    .padding(.horizontal, 24)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weekly Feedback Alert")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text("Get your weekly insights")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $weeklyFeedbackOn)
                        .tint(Color.offAccent)
                        .labelsHidden()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)

                Divider()
                    .background(Color.offStroke)
                    .padding(.horizontal, 24)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pattern Insights")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text("Notifications about detected patterns")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $patternInsightsOn)
                        .tint(Color.offAccent)
                        .labelsHidden()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    func accountActionRow(icon: String, title: String, subtitle: String, iconColor: Color) -> some View {
        Button { } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(iconColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text(subtitle)
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
        .buttonStyle(.plain)
    }

    var deleteDataButton: some View {
        Button { } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.offWarn.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offWarn)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Delete All Data")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.offWarn)

                        Text("Permanently remove all app data")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer()
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
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .withPreviewManagers()
}
