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

    init(selection: FamilyActivitySelection = FamilyActivitySelection()) {
        self.selection = selection
    }

    func loadSelectedActivities() throws -> FamilyActivitySelection {
        selection
    }

    func saveSelectedActivities(_ selection: FamilyActivitySelection) throws {
        self.selection = selection
    }
}
