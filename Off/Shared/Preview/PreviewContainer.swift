//
//  PreviewContainer.swift
//  Off
//

import SwiftUI

@MainActor
struct PreviewContainer {

    static let appState = AppState()
    static let screenTimeManager = ScreenTimeManager(store: MockActivitySelectionStore())
    static let onboardingManager = OnboardingManager()
    static let bootstrapManager = BootstrapManager()
    static let statsManager = StatsManager()
    static let usageManager = UsageManager()
    static let attributeManager = AttributeManager(store: MockAttributeStore())
    static let planManager = PlanManager(store: MockPlanStore())
    static let checkInManager = CheckInManager(store: MockCheckInStore())
    static let urgeManager = UrgeManager(store: MockUrgeStore())
    static let insightManager = InsightManager(store: MockInsightStore(), aiService: MockAIService())

    static func bootstrap() {
        bootstrapManager.bootstrap(
            screenTimeManager: screenTimeManager,
            usageManager: usageManager,
            planManager: planManager,
            checkInManager: checkInManager,
            attributeManager: attributeManager,
            insightManager: insightManager,
            urgeManager: urgeManager,
            statsManager: statsManager
        )
    }
}

extension View {

    func withPreviewManagers() -> some View {
        self
            .environment(PreviewContainer.appState)
            .environment(PreviewContainer.screenTimeManager)
            .environment(PreviewContainer.onboardingManager)
            .environment(PreviewContainer.attributeManager)
            .environment(PreviewContainer.planManager)
            .environment(PreviewContainer.checkInManager)
            .environment(PreviewContainer.urgeManager)
            .environment(PreviewContainer.insightManager)
            .environment(PreviewContainer.statsManager)
            .environment(PreviewContainer.usageManager)
            .environment(PreviewContainer.bootstrapManager)
            .task { PreviewContainer.bootstrap() }
    }
}
