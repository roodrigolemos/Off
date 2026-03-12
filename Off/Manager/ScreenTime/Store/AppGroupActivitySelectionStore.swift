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
        if let data = defaults.data(forKey: "screenTimeActivitySelection") {
            return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
        }

        return FamilyActivitySelection()
    }

    func saveSelectedActivities(_ selection: FamilyActivitySelection) throws {
        let data = try PropertyListEncoder().encode(selection)
        defaults.set(data, forKey: "screenTimeActivitySelection")
    }
}
