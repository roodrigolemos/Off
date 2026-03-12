//
//  ActivitySelectionStore.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import FamilyControls

@MainActor
protocol ActivitySelectionStore {
    func loadSelectedActivities() throws -> FamilyActivitySelection
    func saveSelectedActivities(_ selection: FamilyActivitySelection) throws
}
