//
//  InsightManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class InsightManager {

    private let store: InsightStore
    private let aiService: AIService

    var weeklyInsightState: WeeklyInsightState = .notYetAvailable
    var currentInsight: InsightSnapshot?
    var isGenerating: Bool = false
    var error: InsightError?

    init(store: InsightStore, aiService: AIService) {
        self.store = store
        self.aiService = aiService
    }

    // MARK: - Availability

    func checkWeeklyInsightAvailability(plan: PlanSnapshot?, checkIns: [CheckInSnapshot]) {
        let lastMonday = Date.lastWeekMonday()

        do {
            if let existing = try store.fetchForWeekStart(lastMonday) {
                currentInsight = existing
                weeklyInsightState = .viewed
                return
            }
        } catch {
            weeklyInsightState = .notYetAvailable
            return
        }

        // First week — plan was created this week
        if let plan {
            let thisMonday = Date.thisWeekMonday()
            let planStart = Calendar.current.startOfDay(for: plan.firstPlanCreatedAt)
            if planStart >= thisMonday {
                weeklyInsightState = .notYetAvailable
                return
            }
        } else {
            weeklyInsightState = .notYetAvailable
            return
        }

        weeklyInsightState = .ready
    }

    func markAsViewed() {
        weeklyInsightState = .viewed
    }

    // MARK: - Load / Generate (triggered from WeeklyInsightDetailView .task)

    func prepareInsightIfNeeded(
        plan: PlanSnapshot?,
        checkIns: [CheckInSnapshot],
        interventions: [UrgeSnapshot]
    ) async {
        guard currentInsight == nil else { return }

        let lastMonday = Date.lastWeekMonday()
        let lastSunday = Calendar.current.date(byAdding: .day, value: 6, to: lastMonday) ?? lastMonday

        let lastWeekCheckIns = checkIns.filter { checkIn in
            let day = Calendar.current.startOfDay(for: checkIn.date)
            return day >= lastMonday && day <= lastSunday
        }

        guard lastWeekCheckIns.count >= 4 else {
            error = .insufficientData
            return
        }

        isGenerating = true
        defer { isGenerating = false }

        let previousInsights = (try? store.fetchAll()) ?? []

        do {
            let data = aggregateData(
                plan: plan,
                checkIns: checkIns,
                lastWeekCheckIns: lastWeekCheckIns,
                lastMonday: lastMonday,
                interventions: interventions,
                previousInsights: previousInsights
            )

            let response = try await aiService.generateWeeklyInsight(data: data)

            let snapshot = InsightSnapshot(
                weekStartDate: lastMonday,
                whatsHappening: response.whatsHappening,
                whyThisHappens: response.whyThisHappens,
                whatToExpect: response.whatToExpect,
                patternIdentified: response.patternIdentified
            )

            do {
                try store.save(snapshot)
                if let saved = try? store.fetchForWeekStart(snapshot.weekStartDate) {
                    currentInsight = saved
                }
                error = nil
            } catch {
                self.error = .saveFailed
            }
        } catch {
            self.error = .generationFailed
        }
    }

    // MARK: - Data Aggregation

    private func aggregateData(
        plan: PlanSnapshot?,
        checkIns: [CheckInSnapshot],
        lastWeekCheckIns: [CheckInSnapshot],
        lastMonday: Date,
        interventions: [UrgeSnapshot],
        previousInsights: [InsightSnapshot]
    ) -> WeeklyInsightData {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Week number since plan creation
        let weekNumber: Int
        if let plan {
            let planStart = calendar.startOfDay(for: plan.firstPlanCreatedAt)
            let weeks = calendar.dateComponents([.weekOfYear], from: planStart, to: lastMonday).weekOfYear ?? 1
            weekNumber = max(1, weeks + 1)
        } else {
            weekNumber = 1
        }

        // Plan description
        let planDescription: String
        if let plan {
            let dayNames = formatPlanDays(plan.days)
            planDescription = "\(plan.displayName) — \(plan.timeBoundary.rawValue) — \(dayNames)"
        } else {
            planDescription = "No active plan"
        }

        // Current week check-ins
        let currentWeekDataPoints = lastWeekCheckIns
            .sorted { $0.date < $1.date }
            .map { toDataPoint($0, formatter: dateFormatter) }

        // Previous weeks (up to 3)
        var previousWeeksCheckIns: [[CheckInDataPoint]] = []
        for weeksBack in 2...4 {
            guard let weekStart = calendar.date(byAdding: .day, value: -7 * weeksBack, to: Date.thisWeekMonday()) else { continue }
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart

            let weekCheckIns = checkIns.filter { checkIn in
                let day = calendar.startOfDay(for: checkIn.date)
                return day >= weekStart && day <= weekEnd
            }

            guard !weekCheckIns.isEmpty else { continue }

            let dataPoints = weekCheckIns
                .sorted { $0.date < $1.date }
                .map { toDataPoint($0, formatter: dateFormatter) }
            previousWeeksCheckIns.append(dataPoints)
        }

        // Urge data from last week
        let lastSunday = calendar.date(byAdding: .day, value: 6, to: lastMonday) ?? lastMonday
        let lastWeekInterventions = interventions.filter { intervention in
            let day = calendar.startOfDay(for: intervention.timestamp)
            return day >= lastMonday && day <= lastSunday
        }

        let urgeData: UrgeDataSummary?
        if !lastWeekInterventions.isEmpty {
            let completed = lastWeekInterventions.filter { $0.completedFull }
            let resisted = lastWeekInterventions.filter { $0.finalChoice == .resisted }.count
            let usedAnyway = lastWeekInterventions.filter { $0.finalChoice == .usedAnyway }.count
            let completionRate = Double(completed.count) / Double(lastWeekInterventions.count)

            let reasons = lastWeekInterventions.compactMap { $0.seekingWhat }
            let reasonCounts = Dictionary(grouping: reasons, by: { $0 }).mapValues { $0.count }
            let mostCommon = reasonCounts.max(by: { $0.value < $1.value })?.key

            urgeData = UrgeDataSummary(
                totalCount: lastWeekInterventions.count,
                completionRate: completionRate,
                resistedCount: resisted,
                usedAnywayCount: usedAnyway,
                mostCommonReason: mostCommon?.realityTitle
            )
        } else {
            urgeData = nil
        }

        // Previous insight summaries (up to 3)
        let prevSummaries = previousInsights
            .sorted { $0.weekStartDate > $1.weekStartDate }
            .prefix(3)
            .map { $0.whatsHappening }

        return WeeklyInsightData(
            weekNumber: weekNumber,
            planDescription: planDescription,
            currentWeekCheckIns: currentWeekDataPoints,
            previousWeeksCheckIns: previousWeeksCheckIns,
            urgeData: urgeData,
            previousInsights: Array(prevSummaries)
        )
    }

    private func toDataPoint(_ checkIn: CheckInSnapshot, formatter: DateFormatter) -> CheckInDataPoint {
        CheckInDataPoint(
            date: formatter.string(from: checkIn.date),
            clarity: checkIn.clarity.rawValue,
            focus: checkIn.focus.rawValue,
            energy: checkIn.energy.rawValue,
            drive: checkIn.drive.rawValue,
            patience: checkIn.patience.rawValue,
            control: checkIn.control.rawValue,
            urgeLevel: checkIn.urgeLevel.rawValue,
            planAdherence: checkIn.planAdherence?.rawValue
        )
    }

    private func formatPlanDays(_ days: DaysOfWeek) -> String {
        if days == .everyday { return "Everyday" }
        if days == .weekdays { return "Weekdays" }
        if days == .weekends { return "Weekends" }
        return "Custom days"
    }

    func weeksSincePlanCreation(plan: PlanSnapshot?) -> Int {
        guard let plan else { return 0 }
        let calendar = Calendar.current
        let planStart = calendar.startOfDay(for: plan.firstPlanCreatedAt)
        let weeks = calendar.dateComponents([.weekOfYear], from: planStart, to: Date.thisWeekMonday()).weekOfYear ?? 0
        return max(1, weeks + 1)
    }
}
