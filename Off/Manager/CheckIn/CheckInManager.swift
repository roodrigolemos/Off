//
//  CheckInManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class CheckInManager {

    private let store: CheckInStore

    var checkIns: [CheckInSnapshot] = []
    var error: CheckInError?

    var hasCheckedInToday: Bool {
        checkIns.contains { Calendar.current.isDateInToday($0.date) }
    }

    init(store: CheckInStore) {
        self.store = store
    }

    func loadCheckIns() {
        do {
            checkIns = try store.fetchAll()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func submitCheckIn(
        _ snapshot: CheckInSnapshot,
        attributeManager: AttributeManager,
        statsManager: StatsManager,
        activePlan: PlanSnapshot?,
        planHistory: [PlanSnapshot],
        interventions: [UrgeSnapshot],
        now: Date = .now
    ) {
        do {
            try store.save(snapshot)
            loadCheckIns()
            guard error == nil else { return }
            attributeManager.refreshState(checkIns: checkIns, now: now)
            guard attributeManager.error == nil else {
                self.error = .saveFailed
                return
            }
            statsManager.recalculate(
                checkIns: checkIns,
                activePlan: activePlan,
                planHistory: planHistory,
                interventions: interventions
            )
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }
}
