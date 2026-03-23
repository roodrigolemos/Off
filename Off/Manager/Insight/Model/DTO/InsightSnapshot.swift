//
//  InsightSnapshot.swift
//  Off
//

import Foundation

struct InsightSnapshot: Identifiable, Equatable {

    let id: UUID
    let weekStartDate: Date
    let generatedAt: Date
    let whatsHappening: String
    let whyThisHappens: String
    let whatToExpect: String
    let patternIdentified: String?

    init(
        id: UUID = UUID(),
        weekStartDate: Date,
        generatedAt: Date = .now,
        whatsHappening: String,
        whyThisHappens: String,
        whatToExpect: String,
        patternIdentified: String? = nil
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.generatedAt = generatedAt
        self.whatsHappening = whatsHappening
        self.whyThisHappens = whyThisHappens
        self.whatToExpect = whatToExpect
        self.patternIdentified = patternIdentified
    }
}

extension InsightSnapshot {

    static let sample = InsightSnapshot(
        weekStartDate: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now,
        whatsHappening: "Your focus improved noticeably this week, especially on days when you followed the evening wind-down plan. Energy was steadier, and taking action felt easier, though control still fluctuates.",
        whyThisHappens: "When you reduce evening screen time, your brain gets more restorative rest. That compounds over days, making sustained attention easier and lowering the friction to begin important tasks.",
        whatToExpect: "If you maintain this pattern, expect focus and energy to stabilize further. Action should feel easier to sustain, while control may improve more gradually.",
        patternIdentified: "Your check-ins show better scores on days after you followed your plan the night before. The evening routine is your strongest lever right now."
    )
}
