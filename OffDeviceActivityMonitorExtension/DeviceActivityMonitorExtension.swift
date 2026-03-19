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
        
        print("📍 intervalDidStart fired - activity: \(activity.rawValue)")
        
        if activity == .scheduleRange {
            print("➡️ scheduleRange started")
            print("today restricted: \(isTodayRestricted())")
            
            setRangeActive(isTodayRestricted())
            refreshShieldState()
        }

        if activity == .scheduleLimit {
            print("➡️ scheduleLimit started")
            refreshShieldState()
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        print("📍 intervalDidEnd fired - activity: \(activity.rawValue)")
        
        if activity == .scheduleRange {
            print("➡️ scheduleRange ended")
            setRangeActive(false)
            refreshShieldState()
        }
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        print("📍 eventDidReachThreshold fired - activity: \(activity.rawValue), event: \(event.rawValue)")
        
        if activity == .scheduleLimit, event == .limit {
            print("➡️ matched scheduleLimit + limit")
            print("today restricted: \(isTodayRestricted())")
            
            if isTodayRestricted() {
                print("✅ setting limit reached today")
                setLimitReachedToday()
            } else {
                print("⛔️ not restricted today, not setting limit reached")
            }
            
            refreshShieldState()
        }
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        print("⚠️ intervalWillStartWarning - activity: \(activity.rawValue)")
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        print("⚠️ intervalWillEndWarning - activity: \(activity.rawValue)")
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        print("⚠️ eventWillReachThresholdWarning - activity: \(activity.rawValue), event: \(event.rawValue)")
    }
}

// MARK: Helper Methods
extension DeviceActivityMonitorExtension {
    
    private func refreshShieldState() {
        do {
            let selection = try loadSelection()

            let todayRestricted = isTodayRestricted()
            let rangeActive = defaults.bool(forKey: AppGroupScreenTimeKeys.rangeActive)
            let limitReached = isLimitReachedToday()
            
            let shouldShield = todayRestricted && (rangeActive || limitReached)

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
    
    private func loadSelection() throws -> FamilyActivitySelection {
        guard let data = defaults.data(forKey: AppGroupScreenTimeKeys.selection) else {
            return FamilyActivitySelection()
        }
        return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }
    
    private func todayIdentifier() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func isLimitReachedToday() -> Bool {
        defaults.string(forKey: AppGroupScreenTimeKeys.limitReachedDay) == todayIdentifier()
    }

    private func setRangeActive(_ isActive: Bool) {
        defaults.set(isActive, forKey: AppGroupScreenTimeKeys.rangeActive)
    }

    private func setLimitReachedToday() {
        defaults.set(todayIdentifier(), forKey: AppGroupScreenTimeKeys.limitReachedDay)
    }
    
    private func loadActiveWeekdays() -> [Int] {
        defaults.array(forKey: AppGroupScreenTimeKeys.activeWeekdays) as? [Int] ?? []
    }
    
    private func currentWeekday() -> Int {
        Calendar.current.component(.weekday, from: Date())
    }
    
    private func isTodayRestricted() -> Bool {
        loadActiveWeekdays().contains(currentWeekday())
    }
}
