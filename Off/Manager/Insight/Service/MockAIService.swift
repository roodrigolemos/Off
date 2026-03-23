//
//  MockAIService.swift
//  Off
//

import Foundation

@MainActor
final class MockAIService: AIService {

    func generateWeeklyInsight(data: WeeklyInsightData) async throws -> AIInsightResponse {
        try await Task.sleep(for: .seconds(1.5))

        return AIInsightResponse(
            whatsHappening: "Your focus improved noticeably this week, especially on days when you followed the evening wind-down plan. Energy was steadier, and taking action felt easier, though control still fluctuates.",
            whyThisHappens: "When you reduce evening screen time, your brain gets more restorative rest. That compounds over days, making sustained attention easier and lowering the friction to begin important tasks.",
            whatToExpect: "If you maintain this pattern, expect focus and energy to stabilize further. Action should feel easier to sustain, while control may improve more gradually.",
            patternIdentified: "Your check-ins show better scores on days after you followed your plan the night before. The evening routine is your strongest lever right now."
        )
    }
}
