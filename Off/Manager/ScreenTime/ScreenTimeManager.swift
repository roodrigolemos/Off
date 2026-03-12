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
        Task {
            await checkAuthorization()
        }
    }
    
    var hasSelectedActivity: Bool {
        !selectedActivities.applicationTokens.isEmpty
        || !selectedActivities.categoryTokens.isEmpty
        || !selectedActivities.webDomainTokens.isEmpty
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .approved
    }
}

// MARK: Authorization
extension ScreenTimeManager {
    
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            self.authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        } catch {
            print("Failed to request authorization: \(error)")
            switch AuthorizationCenter.shared.authorizationStatus {
            case .notDetermined:
                self.authorizationStatus = .notDetermined
            case .denied:
                self.authorizationStatus = .denied
            case .approved:
                self.authorizationStatus = .approved
            @unknown default:
                print("Unknow error")
            }
        }
    }
    
    func checkAuthorization() async {
        self.authorizationStatus = AuthorizationCenter.shared.authorizationStatus
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
}

// MARK: ActivitySchedule
extension ScreenTimeManager {
    
    func startMonitoring(rangeStart: DateComponents,
                         rangeEnd: DateComponents,
                         limitMinutes: Int) {
        startMonitoringRange(start: rangeStart, end: rangeEnd)
        startMonitoringLimit(limitMinutes: limitMinutes)
    }
    
    func startMonitoringRange(start: DateComponents, end: DateComponents) {
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
    
    func startMonitoringLimit(limitMinutes: Int) {
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
