//
//  AIService.swift
//  Off
//

import Foundation

@MainActor
protocol AIService {
    func generateWeeklyInsight(data: WeeklyInsightData) async throws -> AIInsightResponse
}

struct WeeklyInsightData: Encodable {
    let weekNumber: Int
    let planDescription: String
    let currentWeekCheckIns: [CheckInDataPoint]
    let previousWeeksCheckIns: [[CheckInDataPoint]]
    let urgeData: UrgeDataSummary?
    let previousInsights: [String]
}

struct CheckInDataPoint: Encodable {
    let date: String
    let clarity: Int
    let focus: Int
    let energy: Int
    let drive: Int
    let patience: Int
    let control: Int
    let urgeLevel: Int
    let planAdherence: Int?
}

struct UrgeDataSummary: Encodable {
    let totalCount: Int
    let completionRate: Double
    let resistedCount: Int
    let usedAnywayCount: Int
    let mostCommonReason: String?
}

struct AIInsightResponse {
    let whatsHappening: String
    let whyThisHappens: String
    let whatToExpect: String
    let patternIdentified: String?
}
