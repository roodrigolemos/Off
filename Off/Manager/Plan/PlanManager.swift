//
//  PlanManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class PlanManager {

    private let store: PlanStore

    var activePlan: PlanSnapshot?
    var planHistory: [PlanSnapshot] = []
    var error: PlanError?

    var isPlanDay: Bool {
        guard let plan = activePlan else { return false }
        return plan.days.contains(date: .now)
    }

    var hasCompletedFirstWeeklyCycle: Bool {
        guard let plan = activePlan else { return false }
        let calendar = Calendar.current
        let thisWeekMonday = Date.thisWeekMonday()
        let planStart = calendar.startOfDay(for: plan.firstPlanCreatedAt)
        return planStart < thisWeekMonday
    }

    init(store: PlanStore) {
        self.store = store
    }

    func loadPlan() {
        do {
            planHistory = try store.fetchAllPlans()
            activePlan = planHistory.last
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func createPlan(
        name: String,
        timeBoundary: TimeBoundary,
        timeWindows: [TimeWindowValue],
        days: DaysOfWeek,
        lightSupports: Set<LightSupport>
    ) {
        guard validate(name: name, days: days) else { return }
        let normalizedWindows = PlanTimeWindowRules.normalized(timeBoundary: timeBoundary, timeWindows: timeWindows)

        do {
            let now = Date.now
            let snapshot = PlanSnapshot(
                firstPlanCreatedAt: now,
                createdAt: now,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                timeBoundary: timeBoundary,
                timeWindows: normalizedWindows,
                days: days,
                lightSupports: lightSupports
            )
            try store.save(snapshot)
            loadPlan()
        } catch {
            self.error = .saveFailed
        }
    }

    func updateRules(
        name: String,
        timeBoundary: TimeBoundary,
        timeWindows: [TimeWindowValue],
        days: DaysOfWeek,
        lightSupports: Set<LightSupport>
    ) {
        guard let activePlan else {
            error = .noActivePlan
            return
        }
        guard validate(
            name: name,
            days: days
        ) else { return }
        let normalizedWindows = PlanTimeWindowRules.normalized(timeBoundary: timeBoundary, timeWindows: timeWindows)

        do {
            let snapshot = PlanSnapshot(
                firstPlanCreatedAt: activePlan.firstPlanCreatedAt,
                createdAt: .now,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                timeBoundary: timeBoundary,
                timeWindows: normalizedWindows,
                days: days,
                lightSupports: lightSupports
            )
            try store.save(snapshot)
            loadPlan()
        } catch {
            self.error = .saveFailed
        }
    }

    private func validate(name: String,days: DaysOfWeek) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            error = .invalidPlanName
            return false
        }
        guard days.dayCount >= 4 else {
            error = .notEnoughDays
            return false
        }
        return true
    }
}
