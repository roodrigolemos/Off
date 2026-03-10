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
        whatsHappening: "Your focus improved noticeably this week, especially on days when you followed the evening wind-down plan. Energy levels were more consistent, though control still fluctuates.",
        whyThisHappens: "When you reduce evening screen time, your brain gets more restorative rest. This compounds over days, making sustained attention easier and reducing the 'mental fog' feeling.",
        whatToExpect: "If you maintain this pattern, expect clarity and focus to stabilize further. Control tends to improve last — it requires the deepest neural adaptation.",
        patternIdentified: "Your check-ins show better scores on days after you followed your plan the night before. The evening routine is your strongest lever right now."
    )
}
