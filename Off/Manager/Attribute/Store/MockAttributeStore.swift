//
//  MockAttributeStore.swift
//  Off
//

import Foundation

@MainActor
final class MockAttributeStore: AttributeStore {

    func fetchScores() throws -> AttributeScoresSnapshot? {
        AttributeScoresSnapshot(
            scores: [
                .focus: 2.5,
                .control: 2.0,
                .action: 2.5,
                .energy: 3.0
            ],
            momentum: [:],
            lastProcessedMonday: nil,
            updatedAt: .now
        )
    }

    func saveScores(_ snapshot: AttributeScoresSnapshot) throws { }
}
