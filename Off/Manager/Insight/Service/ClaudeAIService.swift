//
//  ClaudeAIService.swift
//  Off
//

import Foundation

@MainActor
final class ClaudeAIService: AIService {

    private static let apiKey = "REPLACE_WITH_ANTHROPIC_API_KEY"

    func generateWeeklyInsight(data: WeeklyInsightData) async throws -> AIInsightResponse {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(Self.apiKey, forHTTPHeaderField: "x-api-key")

        let systemPrompt = """
        You are a behavioral insight analyst for a digital wellness app. The user is reducing social media usage. \
        Analyze their weekly check-in data and return a JSON object with exactly these fields:
        - "whatsHappening": 2-3 sentences describing observable patterns in their data this week
        - "whyThisHappens": 2-3 sentences explaining the neuroscience/psychology behind the patterns
        - "whatToExpect": 2-3 sentences projecting what they can expect if they continue
        - "patternIdentified": 1-2 sentences about a specific pattern, or null if none stands out

        Return ONLY valid JSON, no markdown, no explanation.
        """

        let encoder = JSONEncoder()
        let userData = try encoder.encode(data)
        let userMessage = String(data: userData, encoding: .utf8) ?? "{}"

        let body: [String: Any] = [
            "model": "claude-sonnet-4-5-20250929",
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userMessage]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (responseData, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw InsightError.generationFailed
        }

        return try parseResponse(responseData)
    }

    private func parseResponse(_ data: Data) throws -> AIInsightResponse {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw InsightError.generationFailed
        }

        guard let jsonData = text.data(using: .utf8),
              let parsed = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let whatsHappening = parsed["whatsHappening"] as? String,
              let whyThisHappens = parsed["whyThisHappens"] as? String,
              let whatToExpect = parsed["whatToExpect"] as? String else {
            throw InsightError.generationFailed
        }

        let patternIdentified = parsed["patternIdentified"] as? String

        return AIInsightResponse(
            whatsHappening: whatsHappening,
            whyThisHappens: whyThisHappens,
            whatToExpect: whatToExpect,
            patternIdentified: patternIdentified
        )
    }
}
