//
//  WeeklyInsight.swift
//  Off
//

import Foundation
import SwiftData

@Model
final class WeeklyInsight {

    var id: UUID
    var weekStartDate: Date
    var generatedAt: Date
    var whatsHappening: String
    var whyThisHappens: String
    var whatToExpect: String
    var patternIdentified: String?

    init(from snapshot: InsightSnapshot) {
        self.id = snapshot.id
        self.weekStartDate = snapshot.weekStartDate
        self.generatedAt = snapshot.generatedAt
        self.whatsHappening = snapshot.whatsHappening
        self.whyThisHappens = snapshot.whyThisHappens
        self.whatToExpect = snapshot.whatToExpect
        self.patternIdentified = snapshot.patternIdentified
    }

    func toSnapshot() -> InsightSnapshot {
        InsightSnapshot(
            id: id,
            weekStartDate: weekStartDate,
            generatedAt: generatedAt,
            whatsHappening: whatsHappening,
            whyThisHappens: whyThisHappens,
            whatToExpect: whatToExpect,
            patternIdentified: patternIdentified
        )
    }
}
