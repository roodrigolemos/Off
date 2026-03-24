//
//  MockAttributeStore.swift
//  Off
//

import Foundation

@MainActor
final class MockAttributeStore: AttributeStore {

    func fetchState() throws -> AttributeStateSnapshot? {
        AttributeStateSnapshot(
            currentStates: [
                .focus: 1.8,
                .control: 0.6,
                .action: 2.4,
                .energy: -0.4
            ],
            baselineStates: [
                .focus: 2.0,
                .control: 0.0,
                .action: 2.0,
                .energy: 0.0
            ],
            initializedAt: Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now,
            updatedAt: .now
        )
    }

    func saveState(_ snapshot: AttributeStateSnapshot) throws { }
}
