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
            whatsHappening: "Your focus improved noticeably this week, especially on days when you followed the evening wind-down plan. Energy levels were more consistent, though control still fluctuates.",
            whyThisHappens: "When you reduce evening screen time, your brain gets more restorative rest. This compounds over days, making sustained attention easier and reducing the 'mental fog' feeling.",
            whatToExpect: "If you maintain this pattern, expect clarity and focus to stabilize further. Control tends to improve last — it requires the deepest neural adaptation.",
            patternIdentified: "Your check-ins show better scores on days after you followed your plan the night before. The evening routine is your strongest lever right now."
        )
    }
}
