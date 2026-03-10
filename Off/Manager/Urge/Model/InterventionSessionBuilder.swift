//
//  InterventionSessionBuilder.swift
//  Off
//

import Foundation

struct InterventionSessionBuilder {

    let id: UUID
    let timestamp: Date
    var predictedFeeling: PredictedFeeling?
    var seekingWhat: UrgeReason?
    var memoryOfSuccess: MemoryOfSuccess?
    var finalChoice: FinalChoice?
    var screenReached: Int = 0

    mutating func advanceTo(_ screen: Int) {
        screenReached = max(screenReached, screen)
    }

    func buildSnapshot(completedFull: Bool) -> UrgeSnapshot {
        UrgeSnapshot(
            id: id,
            timestamp: timestamp,
            predictedFeeling: predictedFeeling,
            seekingWhat: seekingWhat,
            memoryOfSuccess: memoryOfSuccess,
            finalChoice: finalChoice,
            completedFull: completedFull,
            screenReached: screenReached
        )
    }
}
