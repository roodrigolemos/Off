//
//  DeviceActivityMonitorExtension.swift
//  OffDeviceActivityMonitorExtension
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let defaults: UserDefaults = UserDefaults(suiteName: "group.appappnomi.Off") ?? .standard
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        if activity.rawValue == "scheduleRange" {
             setRangeActive(true)
             refreshShieldState()
         }

         if activity.rawValue == "scheduleLimit" {
             // new day started for the limit monitor
             // optional explicit reset:
             clearLimitReachedDay()
             refreshShieldState()
         }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        if activity.rawValue == "scheduleRange" {
            setRangeActive(false)
            refreshShieldState()
        }
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        if activity.rawValue == "scheduleLimit", event.rawValue == "limit" {
            setLimitReachedToday()
            refreshShieldState()
        }
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
    }
}

private enum ScreenTimeKeys {
    static let selection = "screenTimeActivitySelection"
    static let rangeActive = "screenTimeRangeActive"
    static let limitReachedDay = "screenTimeLimitReachedDay"
}

// MARK: Helper Methods
extension DeviceActivityMonitorExtension {
    
    private func todayIdentifier() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func isLimitReachedToday() -> Bool {
        defaults.string(forKey: ScreenTimeKeys.limitReachedDay) == todayIdentifier()
    }

    private func setRangeActive(_ isActive: Bool) {
        defaults.set(isActive, forKey: ScreenTimeKeys.rangeActive)
    }

    private func setLimitReachedToday() {
        defaults.set(todayIdentifier(), forKey: ScreenTimeKeys.limitReachedDay)
    }

    private func clearLimitReachedDay() {
        defaults.removeObject(forKey: ScreenTimeKeys.limitReachedDay)
    }

    private func loadSelection() throws -> FamilyActivitySelection {
        guard let data = defaults.data(forKey: ScreenTimeKeys.selection) else {
            return FamilyActivitySelection()
        }
        return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }
    
    private func refreshShieldState() {
        do {
            let selection = try loadSelection()

            let rangeActive = defaults.bool(forKey: ScreenTimeKeys.rangeActive)
            let limitReached = isLimitReachedToday()
            let shouldShield = rangeActive || limitReached

            if shouldShield {
                store.shield.applications =
                    selection.applicationTokens.isEmpty ? nil : selection.applicationTokens

                store.shield.applicationCategories =
                    selection.categoryTokens.isEmpty
                    ? nil
                    : .specific(selection.categoryTokens, except: Set<ApplicationToken>())

                store.shield.webDomains =
                    selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
            } else {
                store.shield.applications = nil
                store.shield.applicationCategories = nil
                store.shield.webDomains = nil
            }
        } catch {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
        }
    }
}
