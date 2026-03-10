//
//  MockPlanStore.swift
//  Off
//

import Foundation

@MainActor
final class MockPlanStore: PlanStore {

    func fetchActivePlan() throws -> PlanSnapshot? {
        try fetchAllPlans().last
    }

    func fetchAllPlans() throws -> [PlanSnapshot] {
        let calendar = Calendar.current
        let fortyFiveDaysAgo = calendar.date(byAdding: .day, value: -45, to: .now) ?? .now
        let twentyDaysAgo = calendar.date(byAdding: .day, value: -20, to: .now) ?? .now

        return [
            PlanSnapshot(
                firstPlanCreatedAt: fortyFiveDaysAgo,
                createdAt: fortyFiveDaysAgo,
                name: "Focus Workdays",
                timeBoundary: .always,
                timeWindows: [],
                days: .weekdays,
                lightSupports: []
            ),
            PlanSnapshot(
                firstPlanCreatedAt: fortyFiveDaysAgo,
                createdAt: twentyDaysAgo,
                name: "Lunch Window",
                timeBoundary: .duringWindows,
                timeWindows: [PlanTimeWindowRules.defaultWindow],
                days: .everyday,
                lightSupports: [.notificationsOff, .removeFromHomeScreen, .logOut]
            )
        ]
    }

    func save(_ snapshot: PlanSnapshot) throws { }
}
