//
//  ScreenTimeManager.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation
import Observation
import FamilyControls
import DeviceActivity
import ManagedSettings

@MainActor
@Observable
final class ScreenTimeManager {
    
    private let store: ActivitySelectionStore
    
    var authorizationStatus: FamilyControls.AuthorizationStatus = .notDetermined
    var selectedActivities: FamilyActivitySelection = .init()
    var error: ScreenTimeError?
    var shieldingSyncErrorDescription: String?
    
    init(store: ActivitySelectionStore) {
        self.store = store
        refreshAuthorizationStatus()
    }
    
    var hasSelectedActivity: Bool {
        !selectedActivities.applicationTokens.isEmpty
        || !selectedActivities.categoryTokens.isEmpty
        || !selectedActivities.webDomainTokens.isEmpty
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .approved
    }

    var usageTrackingState: UsageTrackingState {
        UsageTrackingState(isAuthorized: isAuthorized, hasSelection: hasSelectedActivity)
    }

    var selectionDigest: Int {
        var hasher = Hasher()
        hasher.combine(selectedActivities.applicationTokens)
        hasher.combine(selectedActivities.categoryTokens)
        hasher.combine(selectedActivities.webDomainTokens)
        return hasher.finalize()
    }
}

// MARK: Authorization
extension ScreenTimeManager {

    func refreshAuthorizationStatus() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }
    
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            refreshAuthorizationStatus()
            error = nil
        } catch {
            print("Failed to request authorization: \(error)")
            refreshAuthorizationStatus()
            self.error = .requestFailed
        }
    }
    
    func checkAuthorization() async {
        refreshAuthorizationStatus()
    }
}

// MARK: ActivitySelection
extension ScreenTimeManager {
    
    func loadSelection() {
        do {
            selectedActivities = try store.loadSelectedActivities()
            error = nil
        } catch {
            self.error = .loadSelectedActivitiesFailed
        }
    }
    
    func updateSelection(_ selection: FamilyActivitySelection) {
        do {
            try store.saveSelectedActivities(selection)
            selectedActivities = selection
            error = nil
        } catch {
            self.error = .saveSelectedActivitiesFailed
        }
    }
    
    func saveActiveDays(days: [Int]) {
        store.saveActiveWeekdays(days)
    }
    
    func clearLimitReachedToday() {
        store.clearLimitReachedToday()
    }
}

// MARK: ActivitySchedule
extension ScreenTimeManager {
    
    func startMonitoring(rangeStart: DateComponents,
                         rangeEnd: DateComponents,
                         limitMinutes: Int) {
        startMonitoringRange(start: rangeStart, end: rangeEnd)
        startMonitoringLimit(limitMinutes: limitMinutes)
    }
    
    func restartMonitoring(
        rangeStart: DateComponents,
        rangeEnd: DateComponents,
        limitMinutes: Int
    ) {
        stopMonitoring()
        clearLimitReachedToday()
        startMonitoringRange(start: rangeStart, end: rangeEnd)
        startMonitoringLimit(limitMinutes: limitMinutes)
    }
    
    private func stopMonitoring() {
        DeviceActivityCenter().stopMonitoring([.scheduleRange, .scheduleLimit])
    }
    
    private func startMonitoringRange(start: DateComponents, end: DateComponents) {
        let schedule = DeviceActivitySchedule(
            intervalStart: start,
            intervalEnd: end,
            repeats: true
        )

        do {
            try DeviceActivityCenter().startMonitoring(.scheduleRange, during: schedule)
        } catch {
            print("Could not start monitoring range schedule: \(error)")
        }
    }
    
    private func startMonitoringLimit(limitMinutes: Int) {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            .limit: DeviceActivityEvent(
                applications: selectedActivities.applicationTokens,
                categories: selectedActivities.categoryTokens,
                webDomains: selectedActivities.webDomainTokens,
                threshold: DateComponents(minute: limitMinutes),
                includesPastActivity: true
            )
        ]

        do {
            try DeviceActivityCenter().startMonitoring(.scheduleLimit, during: schedule, events: events)
        } catch {
            print("Could not start monitoring limit schedule: \(error)")
        }
    }
}
