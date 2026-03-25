//
//  HomeView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct HomeView: View {

    @Environment(PlanManager.self) var planManager
    @Environment(CheckInManager.self) var checkInManager
    @Environment(UrgeManager.self) var urgeManager
    @Environment(StatsManager.self) var statsManager

    @State private var showCheckIn = false
    @State private var showUrgeIntervention = false
    @State private var isPlanCardFlipped = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.offBackgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        mainCheckInArea
                        insightsGrid
                        weekProgressSection
                    }
                    .padding(.bottom, 48)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showCheckIn, onDismiss: {
                checkInManager.loadCheckIns()
                statsManager.recalculate(
                    checkIns: checkInManager.checkIns,
                    activePlan: planManager.activePlan,
                    planHistory: planManager.planHistory,
                    interventions: urgeManager.interventions
                )
            }) {
                CheckInView()
            }
            .fullScreenCover(isPresented: $showUrgeIntervention, onDismiss: {
                urgeManager.loadInterventions()
                statsManager.recalculate(
                    checkIns: checkInManager.checkIns,
                    activePlan: planManager.activePlan,
                    planHistory: planManager.planHistory,
                    interventions: urgeManager.interventions
                )
            }) {
                UrgeInterventionView()
            }
            .animation(.easeInOut, value: checkInManager.hasCheckedInToday)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showUrgeIntervention = true } label: {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.offAccent)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .withPreviewManagers()
}

// MARK: - Sections

private extension HomeView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(formattedDate)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)

            Text(greeting)
                .font(.system(size: 38, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 36)
    }

    var mainCheckInArea: some View {
        VStack(spacing: 20) {
            if checkInManager.hasCheckedInToday {
                checkInCompletedCard
                    .transition(.opacity)
            } else {
                checkInPromptCard
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }

    var insightsGrid: some View {
        VStack(spacing: 18) {
            HStack(spacing: 18) {
                streakCard
                planCard
            }

            thisWeekCard
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }

    var weekProgressSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("THIS WEEK")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.6)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(statsManager.weekDayCards) { card in
                        dayCard(
                            day: card.dayLabel,
                            date: card.dateNumber,
                            isToday: card.isToday,
                            hasCheckIn: card.checkIn != nil,
                            attributes: attributesForCard(card),
                            urgeText: card.checkIn?.urgeLevel.label
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - Helper Views

private extension HomeView {
    
    var checkInPromptCard: some View {
        Button { showCheckIn = true } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.offAccent.opacity(0.03),
                                Color.offAccentSoft.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How's your\nmind today?")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundStyle(Color.offTextPrimary)
                            .lineSpacing(4)

                        Text("Tap to begin check-in")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.offTextSecondary)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.offAccent, Color.offAccent.opacity(0.75)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)

                        Circle()
                            .fill(Color.offAccent.opacity(0.15))
                            .frame(width: 78, height: 78)

                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(28)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.offAccent.opacity(0.2),
                                Color.offAccent.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.offAccent.opacity(0.06), radius: 20, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
    
    var checkInCompletedCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offSuccess.opacity(0.03),
                            Color.offSuccess.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Check-in\ncomplete")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .lineSpacing(4)

                    Text("See you tomorrow")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.offSuccess, Color.offSuccess.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)

                    Circle()
                        .fill(Color.offSuccess.opacity(0.15))
                        .frame(width: 78, height: 78)

                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(28)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.offSuccess.opacity(0.2),
                            Color.offSuccess.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.offSuccess.opacity(0.06), radius: 20, x: 0, y: 8)
    }

    var streakCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
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
                                endRadius: 25
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(statsManager.streakMetrics.current)")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundStyle(Color.offTextPrimary)
                        .tracking(-0.5)

                    Text("Day streak")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.offTextSecondary)
                        .tracking(0.3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var planCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.offAccentSoft.opacity(0.5),
                            Color.offAccentSoft.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            ZStack {
                planCardFront
                    .opacity(isPlanCardFlipped ? 0 : 1)

                planCardBack
                    .opacity(isPlanCardFlipped ? 1 : 0)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.offAccent.opacity(0.3),
                            Color.offAccent.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.offAccent.opacity(0.08), radius: 12, x: 0, y: 6)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                isPlanCardFlipped.toggle()
            }
        }
    }

    var planCardFront: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 44, height: 44)

                Image(systemName: planManager.activePlan?.displayIcon ?? PlanVisuals.defaultIcon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 6) {
                Text(planCardDisplayName)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)
                    .lineSpacing(3)

                Text("Active plan")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
                    .tracking(0.3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
    }

    var planCardBack: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let plan = planManager.activePlan {
                Text("PLAN DETAILS")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(Color.offAccent)
                    .tracking(1.4)

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    if let blockedText = planCardBlockedText(for: plan) {
                        planCardDetailRow(label: "BLOCKED", value: blockedText)
                    }

                    planCardDetailRow(label: "DAYS", value: planCardDaysText(for: plan))

                    if let actionsText = planCardActionsText(for: plan) {
                        planCardDetailRow(label: "ACTIONS", value: actionsText)
                    }
                }
            } else {
                Spacer()

                Text("No plan configured")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextMuted)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
    }

    func planCardDetailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(Color.offTextMuted)
                .tracking(1.2)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.offTextPrimary)
        }
    }

    var thisWeekCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("THIS WEEK")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color.offTextMuted)
                        .tracking(1.6)

                    Text("Your week")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }

                Spacer()

                HStack(spacing: 6) {
                    ForEach(statsManager.weekDays) { day in
                        dayDot(label: day.label, state: day.state)
                    }
                }
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

    func dayDot(label: String, state: DayAdherenceState) -> some View {
        VStack(spacing: 6) {
            Group {
                switch state {
                case .followed:
                    Circle()
                        .fill(Color.offAccent)
                        .frame(width: 8, height: 8)
                case .partially:
                    Circle()
                        .fill(Color.offAccent.opacity(0.4))
                        .frame(width: 8, height: 8)
                case .notFollowed, .missed:
                    Circle()
                        .fill(Color.offWarn)
                        .frame(width: 8, height: 8)
                case .pending:
                    Circle()
                        .stroke(Color.offAccent, lineWidth: 1)
                        .frame(width: 8, height: 8)
                case .upcoming:
                    Circle()
                        .stroke(Color.offStroke, lineWidth: 1)
                        .frame(width: 8, height: 8)
                case .restDay:
                    Circle()
                        .fill(Color.offDotInactive)
                        .frame(width: 8, height: 8)
                }
            }

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(state == .upcoming || state == .restDay ? Color.offTextMuted : Color.offTextSecondary)
        }
    }

    func dayCard(
        day: String,
        date: String,
        isToday: Bool,
        hasCheckIn: Bool,
        attributes: [(icon: String, arrow: String, color: Color)],
        urgeText: String?
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.offBackgroundSecondary)

            if isToday {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.offAccent.opacity(0.06),
                                Color.offAccentSoft.opacity(0.08)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text(day)
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(isToday ? Color.offAccent : Color.offTextMuted)
                        .tracking(1.2)

                    Text(date)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.offTextSecondary)
                }

                if hasCheckIn {
                    VStack(spacing: 6) {
                        if attributes.count >= 2 {
                            HStack(spacing: 12) {
                                attributeItem(icon: attributes[0].icon, arrow: attributes[0].arrow, color: attributes[0].color)
                                attributeItem(icon: attributes[1].icon, arrow: attributes[1].arrow, color: attributes[1].color)
                            }
                        }
                        if attributes.count >= 4 {
                            HStack(spacing: 12) {
                                attributeItem(icon: attributes[2].icon, arrow: attributes[2].arrow, color: attributes[2].color)
                                attributeItem(icon: attributes[3].icon, arrow: attributes[3].arrow, color: attributes[3].color)
                            }
                        }
                        if attributes.count >= 6 {
                            HStack(spacing: 12) {
                                attributeItem(icon: attributes[4].icon, arrow: attributes[4].arrow, color: attributes[4].color)
                                attributeItem(icon: attributes[5].icon, arrow: attributes[5].arrow, color: attributes[5].color)
                            }
                        }
                    }

                    if let urgeText {
                        Text(urgeText)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color.offTextMuted)
                            .tracking(0.2)
                            .padding(.top, 2)
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("–")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(Color.offTextMuted.opacity(0.4))

                        Text("No check-in")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.offTextMuted)
                            .tracking(0.2)
                    }
                    .frame(height: 80)
                }
            }
            .frame(width: 100)
            .padding(.vertical, 18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isToday ? Color.offAccent.opacity(0.25) : Color.offStroke, lineWidth: isToday ? 1.5 : 1)
        )
        .shadow(color: isToday ? Color.offAccent.opacity(0.08) : Color.black.opacity(0.02), radius: isToday ? 12 : 6, x: 0, y: isToday ? 6 : 3)
    }

    func attributeItem(icon: String, arrow: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.offAccent)

            Image(systemName: arrow)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Helpers

private extension HomeView {

    var formattedDate: String {
        Date.now.formatted(
            .dateTime.weekday(.wide).month(.abbreviated).day()
        ).uppercased()
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var planCardDisplayName: String {
        guard let name = planManager.activePlan?.displayName else { return "No Plan" }
        if let spaceIndex = name.firstIndex(of: " ") {
            var result = name
            result.replaceSubrange(spaceIndex...spaceIndex, with: "\n")
            return result
        }
        return name
    }

    func planCardBlockedText(for plan: PlanSnapshot) -> String? {
        switch plan.timeBoundary {
        case .duringWindows:
            guard let window = plan.timeWindows.first else { return "Blocked" }
            return "\(formatTime(hour: window.startHour, minute: window.startMinute))–\(formatTime(hour: window.endHour, minute: window.endMinute))"
        case .always:
            return "Always"
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

    func planCardDaysText(for plan: PlanSnapshot) -> String {
        if plan.days == .everyday { return "Everyday" }
        if plan.days == .weekdays { return "Weekdays" }
        if plan.days == .weekends { return "Weekends" }
        return "Custom"
    }

    func attributesForCard(_ card: WeekDayCardData) -> [(icon: String, arrow: String, color: Color)] {
        guard let checkIn = card.checkIn else { return [] }

        func attributeArrowColor(_ rating: AttributeRating) -> (String, Color) {
            switch rating {
            case .worse:  ("arrow.down", Color.offWarn)
            case .same:   ("equal", Color.offTextMuted)
            case .better: ("arrow.up", Color.offAccent)
            }
        }

        func controlArrowColor(_ rating: ControlRating) -> (String, Color) {
            switch rating {
            case .automatic: ("arrow.down", Color.offWarn)
            case .same:      ("equal", Color.offTextMuted)
            case .conscious: ("arrow.up", Color.offAccent)
            }
        }

        let focus = attributeArrowColor(checkIn.focus)
        let control = controlArrowColor(checkIn.control)
        let action = attributeArrowColor(checkIn.action)
        let energy = attributeArrowColor(checkIn.energy)

        return [
            ("scope", focus.0, focus.1),
            ("hand.raised.slash.fill", control.0, control.1),
            ("flag.checkered", action.0, action.1),
            ("bolt.fill", energy.0, energy.1)
        ]
    }

    func planCardActionsText(for plan: PlanSnapshot) -> String? {
        var actions: [String] = []
        if plan.lightSupports.contains(.removeFromHomeScreen) { actions.append("Hide") }
        if plan.lightSupports.contains(.notificationsOff) { actions.append("Mute") }
        if plan.lightSupports.contains(.logOut) { actions.append("Logout") }
        return actions.isEmpty ? nil : actions.joined(separator: " · ")
    }

}
