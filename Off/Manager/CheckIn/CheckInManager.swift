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

    func save(_ snapshot: CheckInSnapshot) {
        do {
            try store.save(snapshot)
            loadCheckIns()
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }
}
