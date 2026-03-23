//
//  UsageManager.swift
//  Off
//

import Observation

@MainActor
@Observable
final class UsageManager {

    var snapshot = UsageProgressSnapshot(state: .requiredScreenTimePermission)

    func recalculate(trackingState: UsageTrackingState) {
        if !trackingState.isAuthorized {
            snapshot = UsageProgressSnapshot(state: .requiredScreenTimePermission)
        } else if !trackingState.hasSelection {
            snapshot = UsageProgressSnapshot(state: .requiredSelection)
        } else {
            snapshot = UsageProgressSnapshot(state: .usageEnabled)
        }
    }
}
