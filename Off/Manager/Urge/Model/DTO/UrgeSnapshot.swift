//
//  UrgeSnapshot.swift
//  Off
//

import Foundation

struct UrgeSnapshot: Identifiable, Equatable {

    let id: UUID
    let timestamp: Date
    let predictedFeeling: PredictedFeeling?
    let seekingWhat: UrgeReason?
    let memoryOfSuccess: MemoryOfSuccess?
    let finalChoice: FinalChoice?
    let completedFull: Bool
    let screenReached: Int

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        predictedFeeling: PredictedFeeling?,
        seekingWhat: UrgeReason?,
        memoryOfSuccess: MemoryOfSuccess?,
        finalChoice: FinalChoice?,
        completedFull: Bool,
        screenReached: Int
    ) {
        self.id = id
        self.timestamp = timestamp
        self.predictedFeeling = predictedFeeling
        self.seekingWhat = seekingWhat
        self.memoryOfSuccess = memoryOfSuccess
        self.finalChoice = finalChoice
        self.completedFull = completedFull
        self.screenReached = screenReached
    }
}

extension UrgeSnapshot {
    
    static let sample = UrgeSnapshot(
        timestamp: .now,
        predictedFeeling: .worse,
        seekingWhat: .distraction,
        memoryOfSuccess: .yesIRemember,
        finalChoice: .resisted,
        completedFull: true,
        screenReached: 6
    )
}
