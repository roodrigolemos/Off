//
//  UrgeIntervention.swift
//  Off
//

import Foundation
import SwiftData

@Model
final class UrgeIntervention {

    var id: UUID
    var timestamp: Date
    var predictedFeelingRaw: Int?
    var seekingWhatRaw: Int?
    var memoryOfSuccessRaw: Int?
    var finalChoiceRaw: Int?
    var completedFull: Bool
    var screenReached: Int

    init(from snapshot: UrgeSnapshot) {
        self.id = snapshot.id
        self.timestamp = snapshot.timestamp
        self.predictedFeelingRaw = snapshot.predictedFeeling?.rawValue
        self.seekingWhatRaw = snapshot.seekingWhat?.rawValue
        self.memoryOfSuccessRaw = snapshot.memoryOfSuccess?.rawValue
        self.finalChoiceRaw = snapshot.finalChoice?.rawValue
        self.completedFull = snapshot.completedFull
        self.screenReached = snapshot.screenReached
    }

    func toSnapshot() -> UrgeSnapshot {
        UrgeSnapshot(
            id: id,
            timestamp: timestamp,
            predictedFeeling: predictedFeelingRaw.flatMap { PredictedFeeling(rawValue: $0) },
            seekingWhat: seekingWhatRaw.flatMap { UrgeReason(rawValue: $0) },
            memoryOfSuccess: memoryOfSuccessRaw.flatMap { MemoryOfSuccess(rawValue: $0) },
            finalChoice: finalChoiceRaw.flatMap { FinalChoice(rawValue: $0) },
            completedFull: completedFull,
            screenReached: screenReached
        )
    }
}
