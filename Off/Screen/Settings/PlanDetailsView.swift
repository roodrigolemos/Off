//
//  PlanDetailsView.swift
//  Off
//

import SwiftUI
import FamilyControls

struct PlanDetailsView: View {

    @Environment(PlanManager.self) var planManager
    @Environment(CheckInManager.self) var checkInManager
    @Environment(UrgeManager.self) var urgeManager
    @Environment(StatsManager.self) var statsManager
    @Environment(ScreenTimeManager.self) var screenTimeManager

    @State private var showRulesEditor = false
    @State private var showActivityPicker = false
    @State private var activitySelection = FamilyActivitySelection()
    @State private var alertMessage: String?

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            if let plan = planManager.activePlan {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection(plan)
                        editActionsSection
                        scheduleSection(plan)
                        supportsSection(plan)
                    }
                    .padding(.horizontal, 24)
                }
            } else {
                noPlanView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Plan Details")
        .familyActivityPicker(isPresented: $showActivityPicker, selection: $activitySelection)
        .onAppear {
            loadActivitySelection()
        }
        .onChange(of: showActivityPicker) { _, isPresented in
            guard !isPresented else { return }
            handlePickerDismissal()
            
            guard let plan = planManager.activePlan else { return }
            let startHour = plan.timeWindows.first?.startHour
            let startMinute = plan.timeWindows.first?.startMinute
            let endHour = plan.timeWindows.first?.endHour
            let endMinute = plan.timeWindows.first?.endMinute
            let appsLimit = plan.dailyAppLimit
            
            screenTimeManager.restartMonitoring(rangeStart: DateComponents(hour: startHour, minute: startMinute),
                                                rangeEnd: DateComponents(hour: endHour, minute: endMinute),
                                                limitMinutes: appsLimit)
        }
        .alert(
            "Screen Time Apps",
            isPresented: .init(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            ),
            actions: {
                Button("OK") {
                    alertMessage = nil
                    screenTimeManager.error = nil
                }
            },
            message: {
                Text(alertMessage ?? "")
            }
        )
        .fullScreenCover(isPresented: $showRulesEditor) {
            refreshPlanState()
            
            guard let plan = planManager.activePlan else { return }
            screenTimeManager.saveActiveDays(days: plan.days.selectedDays)
            
            if plan.timeBoundary == .always {
                let startHour = 0
                let startMinute = 0
                let endHour = 23
                let endMinute = 59
                let appsLimit = plan.dailyAppLimit
                
                screenTimeManager.restartMonitoring(rangeStart: DateComponents(hour: startHour, minute: startMinute),
                                                    rangeEnd: DateComponents(hour: endHour, minute: endMinute),
                                                    limitMinutes: appsLimit)
                print("start hour: \(startHour ?? 0), start minute: \(startMinute ?? 0), end hour: \(endHour ?? 0), end minute: \(endMinute ?? 0)")
                print("app limit: \(appsLimit ?? 0)")
            } else {
                let startHour = plan.timeWindows.first?.startHour
                let startMinute = plan.timeWindows.first?.startMinute
                let endHour = plan.timeWindows.first?.endHour
                let endMinute = plan.timeWindows.first?.endMinute
                let appsLimit = plan.dailyAppLimit
                
                screenTimeManager.restartMonitoring(rangeStart: DateComponents(hour: startHour, minute: startMinute),
                                                    rangeEnd: DateComponents(hour: endHour, minute: endMinute),
                                                    limitMinutes: appsLimit)
                print("start hour: \(startHour ?? 0), start minute: \(startMinute ?? 0), end hour: \(endHour ?? 0), end minute: \(endMinute ?? 0)")
                print("app limit: \(appsLimit ?? 0)")
            }
        } content: {
            NavigationStack {
                PlanRulesEditView(dismissFlow: $showRulesEditor)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showRulesEditor = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.offTextSecondary)
                            }
                        }
                    }
            }
        }

    }
}

private extension PlanDetailsView {

    var editActionsSection: some View {
        HStack(spacing: 10) {
            Button {
                showRulesEditor = true
            } label: {
                editActionButton(title: "Edit Rules", icon: "slider.horizontal.3")
            }
            .buttonStyle(.plain)

            Button {
                showActivityPicker = true
            } label: {
                editActionButton(title: "Edit Apps", icon: "apps.iphone")
            }
            .buttonStyle(.plain)
        }
    }

    func headerSection(_ plan: PlanSnapshot) -> some View {
        VStack(spacing: 26) {
            ZStack {
                Circle()
                    .fill(Color.offAccent.opacity(0.12))
                    .frame(width: 64, height: 64)

                Image(systemName: plan.displayIcon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
            }

            VStack(spacing: 8) {
                Text(plan.displayName)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)

                Text("Active for \(plan.activeDays) days")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    func scheduleSection(_ plan: PlanSnapshot) -> some View {
        detailCard(title: "SCHEDULE") {
            VStack(alignment: .leading, spacing: 12) {
                detailRow(icon: "clock.fill", label: "Timing", value: timeDescription(plan))
                detailRow(icon: "calendar", label: "Days", value: daysDescription(plan.days))
            }
        }
    }

    func supportsSection(_ plan: PlanSnapshot) -> some View {
        detailCard(title: "LIGHT SUPPORTS") {
            if plan.lightSupports.isEmpty {
                Text("No light supports selected")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.offTextPrimary)
            } else {
                detailRow(
                    icon: "checklist",
                    label: "Enabled",
                    value: lightSupportsDescription(plan.lightSupports)
                )
            }
        }
    }

    var noPlanView: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 40))
                .foregroundStyle(Color.offTextMuted)

            Text("No active plan")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.offTextSecondary)
        }
    }
}

private extension PlanDetailsView {

    func editActionButton(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
            Text(title)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundStyle(Color.offAccent)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.offAccentSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.offAccent.opacity(0.28), lineWidth: 1)
        )
    }

    func detailCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.offStroke, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
    }

    func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.offAccent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.offTextMuted)

                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.offTextPrimary)
            }
        }
    }
}

private extension PlanDetailsView {

    func loadActivitySelection() {
        activitySelection = screenTimeManager.selectedActivities
    }

    func handlePickerDismissal() {
        guard !showActivityPicker else { return }

        let hasSelection =
            !activitySelection.applicationTokens.isEmpty
            || !activitySelection.categoryTokens.isEmpty
            || !activitySelection.webDomainTokens.isEmpty

        guard hasSelection else {
            activitySelection = screenTimeManager.selectedActivities
            alertMessage = "No app selected. Screen Time shielding needs at least one selected app, category, or website to work."
            return
        }

        screenTimeManager.updateSelection(activitySelection)
        syncAlertFromScreenTimeManager()
    }

    func syncAlertFromScreenTimeManager() {
        alertMessage = screenTimeManager.error?.localizedDescription
    }

    func refreshPlanState() {
        planManager.loadPlan()
        statsManager.recalculate(
            checkIns: checkInManager.checkIns,
            activePlan: planManager.activePlan,
            planHistory: planManager.planHistory,
            interventions: urgeManager.interventions
        )
    }

    func timeDescription(_ plan: PlanSnapshot) -> String {
        switch plan.timeBoundary {
        case .always:
            return "Always"
        case .duringWindows:
            guard let window = plan.timeWindows.first else { return "Scheduled" }
            return "\(formatTime(hour: window.startHour, minute: window.startMinute))–\(formatTime(hour: window.endHour, minute: window.endMinute))"
        }
    }

    func formatTime(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        if minute == 0 {
            return "\(displayHour) \(period)"
        }
        return "\(displayHour):\(String(format: "%02d", minute)) \(period)"
    }

    func daysDescription(_ days: DaysOfWeek) -> String {
        if days == .everyday { return "Everyday" }
        if days == .weekdays { return "Weekdays" }
        if days == .weekends { return "Weekends" }

        let ordered: [(DaysOfWeek, String)] = [
            (.monday, "Mon"), (.tuesday, "Tue"), (.wednesday, "Wed"),
            (.thursday, "Thu"), (.friday, "Fri"), (.saturday, "Sat"), (.sunday, "Sun")
        ]
        let names = ordered.compactMap { days.contains($0.0) ? $0.1 : nil }
        return names.joined(separator: ", ")
    }

    func lightSupportsDescription(_ lightSupports: Set<LightSupport>) -> String {
        let displayOrder: [LightSupport] = [.notificationsOff, .removeFromHomeScreen, .logOut]
        let names = displayOrder.compactMap { lightSupports.contains($0) ? $0.displayName : nil }
        return names.joined(separator: ", ")
    }
}

#Preview {
    NavigationStack {
        PlanDetailsView()
    }
    .withPreviewManagers()
}
