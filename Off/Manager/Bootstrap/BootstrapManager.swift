//
//  BootstrapManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class BootstrapManager {

    func bootstrap(
        screenTimeManager: ScreenTimeManager,
        usageManager: UsageManager,
        planManager: PlanManager,
        checkInManager: CheckInManager,
        attributeManager: AttributeManager,
        insightManager: InsightManager,
        urgeManager: UrgeManager,
        statsManager: StatsManager
    ) {
        screenTimeManager.refreshAuthorizationStatus()
        screenTimeManager.loadSelection()
        planManager.loadPlan()
        attributeManager.loadScores()
        checkInManager.loadCheckIns()
        urgeManager.loadInterventions()
        attributeManager.runWeeklyEvolutionIfNeeded(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
        insightManager.checkWeeklyInsightAvailability(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
        statsManager.recalculate(
            checkIns: checkInManager.checkIns,
            activePlan: planManager.activePlan,
            planHistory: planManager.planHistory,
            interventions: urgeManager.interventions
        )
        usageManager.recalculate(trackingState: screenTimeManager.usageTrackingState)
    }

    func refresh(
        screenTimeManager: ScreenTimeManager,
        usageManager: UsageManager,
        planManager: PlanManager,
        checkInManager: CheckInManager,
        attributeManager: AttributeManager,
        insightManager: InsightManager,
        urgeManager: UrgeManager,
        statsManager: StatsManager
    ) {
        screenTimeManager.refreshAuthorizationStatus()
        screenTimeManager.loadSelection()
        planManager.loadPlan()
        checkInManager.loadCheckIns()
        urgeManager.loadInterventions()
        attributeManager.runWeeklyEvolutionIfNeeded(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
        insightManager.checkWeeklyInsightAvailability(plan: planManager.activePlan, checkIns: checkInManager.checkIns)
        statsManager.recalculate(
            checkIns: checkInManager.checkIns,
            activePlan: planManager.activePlan,
            planHistory: planManager.planHistory,
            interventions: urgeManager.interventions
        )
        usageManager.recalculate(trackingState: screenTimeManager.usageTrackingState)
    }
}
