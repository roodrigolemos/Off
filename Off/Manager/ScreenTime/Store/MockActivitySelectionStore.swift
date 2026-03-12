//
//  MockActivitySelectionStore.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation
import FamilyControls

@MainActor
final class MockActivitySelectionStore: ActivitySelectionStore {
    
    private var selection: FamilyActivitySelection
    private var weekDays: [Int]?

    init(selection: FamilyActivitySelection = FamilyActivitySelection()) {
        self.selection = selection
    }

    func loadSelectedActivities() throws -> FamilyActivitySelection {
        selection
    }

    func saveSelectedActivities(_ selection: FamilyActivitySelection) throws {
        self.selection = selection
    }
    
    func loadActiveWeekdays() -> [Int]? {
        weekDays
    }
    
    func saveActiveWeekdays(_ weekdays: [Int]) {
        self.weekDays = weekdays
    }
}
