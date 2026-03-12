//
//  AppGroupActivitySelectionStore.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation
import FamilyControls

final class AppGroupActivitySelectionStore: ActivitySelectionStore {
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    func loadSelectedActivities() throws -> FamilyActivitySelection {
        if let data = defaults.data(forKey: AppGroupScreenTimeKeys.selection) {
            return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
        }

        return FamilyActivitySelection()
    }

    func saveSelectedActivities(_ selection: FamilyActivitySelection) throws {
        let data = try PropertyListEncoder().encode(selection)
        defaults.set(data, forKey: AppGroupScreenTimeKeys.selection)
    }
    
    func loadActiveWeekdays() -> [Int]? {
        defaults.array(forKey: AppGroupScreenTimeKeys.activeWeekdays) as? [Int]
    }
    
    func saveActiveWeekdays(_ days: [Int]) {
        defaults.set(days, forKey: AppGroupScreenTimeKeys.activeWeekdays)
    }
    
    func clearLimitReachedToday() {
        print("antes: \(defaults.string(forKey: AppGroupScreenTimeKeys.limitReachedDay))")
    //        defaults.removeObject(forKey: AppGroupScreenTimeKeys.limitReachedDay)
        defaults.set(nil, forKey: AppGroupScreenTimeKeys.limitReachedDay)
        print("depois: \(defaults.string(forKey: AppGroupScreenTimeKeys.limitReachedDay))\n\n")
    }
}
