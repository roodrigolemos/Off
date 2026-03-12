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
    
    func saveActiveWeekdays(_ weekdays: [Int]) {
        defaults.set(weekdays, forKey: AppGroupScreenTimeKeys.activeWeekdays)
    }
}
