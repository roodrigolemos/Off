//
//  PlanRulesEditView.swift
//  Off
//

import SwiftUI

struct PlanRulesEditView: View {

    @Environment(PlanManager.self) var planManager

    @Binding var dismissFlow: Bool

    @State private var planName = ""
    @State private var timeBoundary: TimeBoundary = .duringWindows
    @State private var timeWindows: [TimeWindowValue] = [PlanTimeWindowRules.defaultWindow]
    @State private var dailyAppLimit: Int? = nil
    @State private var days: DaysOfWeek = .everyday
    @State private var lightSupports: Set<LightSupport> = []
    @State private var hasLoadedInitialState = false

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    nameCard
                    lightSupportsCard
                    timeCard
                    appLimitCard
                    daysCard
                    saveButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Edit Rules")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !hasLoadedInitialState else { return }
            hasLoadedInitialState = true
            guard let activePlan = planManager.activePlan else { return }
            planName = activePlan.name
            timeBoundary = activePlan.timeBoundary
            timeWindows = activePlan.timeWindows
            normalizeTimeWindows()
            dailyAppLimit = activePlan.dailyAppLimit
            days = activePlan.days
            lightSupports = activePlan.lightSupports
        }
        .onChange(of: timeBoundary) {
            normalizeTimeWindows()
        }
        .alert(
            "Error",
            isPresented: .init(
                get: { planManager.error != nil },
                set: { if !$0 { planManager.error = nil } }
            ),
            actions: { Button("OK") { planManager.error = nil } },
            message: { Text(planManager.error?.localizedDescription ?? "") }
        )
    }
}

// MARK: - Sections

private extension PlanRulesEditView {

    var nameCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "pencil", title: "Plan Name", subtitle: "Give your plan a name")

            TextField("e.g. Night Owl Mode", text: $planName)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextPrimary)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.offBackgroundPrimary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.offStroke, lineWidth: 1)
                )
        }
        .modifier(PlanRulesCardStyle())
    }

    var timeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "clock.fill",
                       title: "Schedule",
                       subtitle: "Required: choose when the plan runs")

            VStack(spacing: 10) {
                timeOption(
                    icon: "clock.fill",
                    label: "Range",
                    description: "Block during a daily time window",
                    selected: timeBoundary == .duringWindows
                ) { timeBoundary = .duringWindows }

                if timeBoundary == .duringWindows {
                    VStack(alignment: .leading, spacing: 8) {
                        timeWindowRow()
                        if let scheduledWindowErrorText {
                            Text(scheduledWindowErrorText)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.offWarn)
                                .padding(.horizontal, 4)
                        }
                    }
                }

                timeOption(
                    icon: "xmark.circle.fill",
                    label: "Always",
                    description: "Block at any time",
                    selected: timeBoundary == .always
                ) { timeBoundary = .always }
            }
        }
        .modifier(PlanRulesCardStyle())
    }

    var appLimitCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "hourglass",
                       title: "App Limit",
                       subtitle: "Required: choose the daily usage limit")

            VStack(spacing: 10) {
                ForEach(PlanAppLimitRules.presetLimits, id: \.self) { limit in
                    appLimitOption(limitMinutes: limit)
                }
            }
        }
        .modifier(PlanRulesCardStyle())
    }

    var availableLightSupports: [LightSupport] {
        [.notificationsOff, .removeFromHomeScreen, .logOut]
    }

    var lightSupportsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "checklist", title: "Light Supports", subtitle: "Optional actions")

            VStack(spacing: 10) {
                ForEach(availableLightSupports, id: \.self) { lightSupport in
                    lightSupportOption(
                        icon: icon(for: lightSupport),
                        label: lightSupport.displayName,
                        description: description(for: lightSupport),
                        isOn: lightSupportBinding(for: lightSupport)
                    )
                }
            }
        }
        .modifier(PlanRulesCardStyle())
    }

    var daysCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            cardHeader(icon: "calendar", title: "When rules apply", subtitle: "Select at least 4 days")

            HStack(spacing: 8) {
                dayPill(label: "M", day: .monday)
                dayPill(label: "T", day: .tuesday)
                dayPill(label: "W", day: .wednesday)
                dayPill(label: "T", day: .thursday)
                dayPill(label: "F", day: .friday)
                dayPill(label: "S", day: .saturday)
                dayPill(label: "S", day: .sunday)
            }
        }
        .modifier(PlanRulesCardStyle())
    }

    var saveButton: some View {
        Button {
            saveRules()
        } label: {
            Text("Save Rules")
                .font(.system(size: 16, weight: .semibold))
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
                .shadow(color: Color.offAccent.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .padding(.top, 8)
        .disabled(!canSaveRules)
        .opacity(canSaveRules ? 1 : 0.45)
    }
}

// MARK: - View Helpers

private extension PlanRulesEditView {

    func cardHeader(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 18
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func timeWindowRow() -> some View {
        HStack(spacing: 8) {
            DatePicker(
                "",
                selection: startTimeBinding(),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()

            Text("–")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextMuted)

            DatePicker(
                "",
                selection: endTimeBinding(),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.offBackgroundPrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
    }

    func timeOption(icon: String, label: String, description: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(selected ? Color.offAccent : Color.offTextSecondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(selected ? Color.offAccent : Color.offDotInactive)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selected ? Color.offAccent.opacity(0.08) : Color.offBackgroundPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? Color.offAccent : Color.offStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func appLimitOption(limitMinutes: Int) -> some View {
        let selected = dailyAppLimit == limitMinutes
        return Button {
            dailyAppLimit = limitMinutes
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "hourglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(selected ? Color.offAccent : Color.offTextSecondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(PlanAppLimitRules.displayText(for: limitMinutes))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text("Daily limit for the selected apps")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(selected ? Color.offAccent : Color.offDotInactive)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selected ? Color.offAccent.opacity(0.08) : Color.offBackgroundPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? Color.offAccent : Color.offStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func lightSupportOption(icon: String, label: String, description: String, isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isOn.wrappedValue ? Color.offAccent : Color.offTextSecondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(isOn.wrappedValue ? Color.offAccent : Color.offDotInactive)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isOn.wrappedValue ? Color.offAccent.opacity(0.08) : Color.offBackgroundPrimary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isOn.wrappedValue ? Color.offAccent : Color.offStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func dayPill(label: String, day: DaysOfWeek) -> some View {
        let isSelected = days.contains(day)
        return Button {
            if isSelected {
                guard days.dayCount > 4 else { return }
                days.remove(day)
            } else {
                days.insert(day)
            }
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(isSelected ? .white : Color.offTextSecondary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isSelected ? Color.offAccent : Color.offBackgroundPrimary)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.offAccent : Color.offStroke, lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.offAccent.opacity(0.25) : .clear, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    func lightSupportBinding(for lightSupport: LightSupport) -> Binding<Bool> {
        Binding(
            get: { lightSupports.contains(lightSupport) },
            set: { isOn in
                if isOn {
                    lightSupports.insert(lightSupport)
                } else {
                    lightSupports.remove(lightSupport)
                }
            }
        )
    }

    func icon(for lightSupport: LightSupport) -> String {
        switch lightSupport {
        case .notificationsOff:
            return "bell.slash.fill"
        case .removeFromHomeScreen:
            return "apps.iphone"
        case .logOut:
            return "rectangle.portrait.and.arrow.right"
        }
    }

    func description(for lightSupport: LightSupport) -> String {
        switch lightSupport {
        case .notificationsOff:
            return "Stop social app push notifications"
        case .removeFromHomeScreen:
            return "Keep social apps out of your home screen"
        case .logOut:
            return "Use extra friction by logging out of your accounts"
        }
    }

    func saveRules() {
        guard let dailyAppLimit else { return }
        let windows = PlanTimeWindowRules.normalized(timeBoundary: timeBoundary, timeWindows: timeWindows)

        planManager.updateRules(
            name: planName,
            timeBoundary: timeBoundary,
            timeWindows: windows,
            dailyAppLimit: dailyAppLimit,
            days: days,
            lightSupports: lightSupports
        )

        if planManager.error == nil {
            dismissFlow = false
        }
    }

    func dateFrom(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? .now
    }

    var canSaveRules: Bool {
        !planName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && days.dayCount >= 4
        && PlanTimeWindowRules.hasValidScheduledWindow(timeBoundary: timeBoundary, timeWindows: timeWindows)
        && dailyAppLimit.map { PlanAppLimitRules.isValid(limitMinutes: $0) } == true
    }

    var scheduledWindowErrorText: String? {
        guard timeBoundary == .duringWindows else { return nil }
        guard !PlanTimeWindowRules.hasValidScheduledWindow(timeBoundary: timeBoundary, timeWindows: timeWindows) else { return nil }
        return "End time must be after start time (same day)."
    }

    func currentScheduledWindow() -> TimeWindowValue {
        PlanTimeWindowRules.normalized(timeBoundary: .duringWindows, timeWindows: timeWindows).first ?? PlanTimeWindowRules.defaultWindow
    }

    func startTimeBinding() -> Binding<Date> {
        Binding(
            get: {
                let window = currentScheduledWindow()
                return dateFrom(hour: window.startHour, minute: window.startMinute)
            },
            set: { newDate in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                var window = currentScheduledWindow()
                window.startHour = comps.hour ?? 0
                window.startMinute = comps.minute ?? 0
                timeWindows = PlanTimeWindowRules.normalized(timeBoundary: .duringWindows, timeWindows: [window])
            }
        )
    }

    func endTimeBinding() -> Binding<Date> {
        Binding(
            get: {
                let window = currentScheduledWindow()
                return dateFrom(hour: window.endHour, minute: window.endMinute)
            },
            set: { newDate in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                var window = currentScheduledWindow()
                window.endHour = comps.hour ?? 0
                window.endMinute = comps.minute ?? 0
                timeWindows = PlanTimeWindowRules.normalized(timeBoundary: .duringWindows, timeWindows: [window])
            }
        )
    }

    func normalizeTimeWindows() {
        timeWindows = PlanTimeWindowRules.normalized(timeBoundary: timeBoundary, timeWindows: timeWindows)
    }
}

// MARK: - PlanRulesCardStyle

private struct PlanRulesCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.offBackgroundSecondary)

                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.offAccent.opacity(0.04), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.offStroke, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        PlanRulesEditView(dismissFlow: .constant(false))
    }
    .withPreviewManagers()
}
