//
//  MockUrgeStore.swift
//  Off
//

import Foundation

@MainActor
final class MockUrgeStore: UrgeStore {

    func fetchAll() throws -> [UrgeSnapshot] {
        [
            UrgeSnapshot(
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: .now) ?? .now,
                predictedFeeling: .worse,
                seekingWhat: .distraction,
                memoryOfSuccess: .yesIRemember,
                finalChoice: .resisted,
                completedFull: true,
                screenReached: 6
            ),
            UrgeSnapshot(
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
                predictedFeeling: .same,
                seekingWhat: .anxiety,
                memoryOfSuccess: .dontRemember,
                finalChoice: .usedAnyway,
                completedFull: true,
                screenReached: 6
            )
        ]
    }

    func save(_ snapshot: UrgeSnapshot) throws { }
}
