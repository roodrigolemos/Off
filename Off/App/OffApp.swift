//
//  OffApp.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI
import SwiftData
import Foundation

enum BuildConfiguration {
    case mock, dev, prod
}

@main
struct OffApp: App {

    @Environment(\.scenePhase) var scenePhase

    @State private var appState: AppState
    @State private var screenTimeManager: ScreenTimeManager
    @State private var onboardingManager: OnboardingManager
    @State private var attributeManager: AttributeManager
    @State private var planManager: PlanManager
    @State private var checkInManager: CheckInManager
    @State private var urgeManager: UrgeManager
    @State private var insightManager: InsightManager
    @State private var statsManager: StatsManager
    @State private var bootstrapManager: BootstrapManager

    private let container: ModelContainer
    private let config: BuildConfiguration
    private let userDefaults: UserDefaults
    private let swiftDataContainerName = "Off.store"

    init() {
        do {
            let schema = Schema([AttributeScores.self, Plan.self, CheckIn.self, UrgeIntervention.self, WeeklyInsight.self])
            let modelConfig = ModelConfiguration(swiftDataContainerName, schema: schema)
            container = try ModelContainer(for: schema, configurations: modelConfig)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
        
        userDefaults = UserDefaults(suiteName: "group.appappnomi.Off") ?? .standard

        #if MOCK
        config = .mock
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif

        _appState = State(initialValue: AppState())
        _onboardingManager = State(initialValue: OnboardingManager())
        _statsManager = State(initialValue: StatsManager())
        _bootstrapManager = State(initialValue: BootstrapManager())

        switch config {
        case .mock:
            _screenTimeManager = State(initialValue: ScreenTimeManager(store: MockActivitySelectionStore()))
            _attributeManager = State(initialValue: AttributeManager(store: MockAttributeStore()))
            _planManager = State(initialValue: PlanManager(store: MockPlanStore()))
            _checkInManager = State(initialValue: CheckInManager(store: MockCheckInStore()))
            _urgeManager = State(initialValue: UrgeManager(store: MockUrgeStore()))
            _insightManager = State(initialValue: InsightManager(store: MockInsightStore(), aiService: MockAIService()))
        case .dev, .prod:
            _screenTimeManager = State(initialValue: ScreenTimeManager(
                store: AppGroupActivitySelectionStore(defaults: userDefaults)
            ))
            _attributeManager = State(initialValue: AttributeManager(
                store: SwiftDataAttributeStore(context: container.mainContext)
            ))
            _planManager = State(initialValue: PlanManager(
                store: SwiftDataPlanStore(context: container.mainContext)
            ))
            _checkInManager = State(initialValue: CheckInManager(
                store: SwiftDataCheckInStore(context: container.mainContext)
            ))
            _urgeManager = State(initialValue: UrgeManager(
                store: SwiftDataUrgeStore(context: container.mainContext)
            ))
            _insightManager = State(initialValue: InsightManager(
                store: SwiftDataInsightStore(context: container.mainContext),
                aiService: ClaudeAIService()
            ))
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .preferredColorScheme(.light)
                .environment(appState)
                .environment(screenTimeManager)
                .environment(onboardingManager)
                .environment(attributeManager)
                .environment(planManager)
                .environment(checkInManager)
                .environment(urgeManager)
                .environment(insightManager)
                .environment(statsManager)
                .environment(bootstrapManager)
                .task {
                    bootstrapManager.bootstrap(
                        screenTimeManager: screenTimeManager,
                        planManager: planManager,
                        checkInManager: checkInManager,
                        attributeManager: attributeManager,
                        insightManager: insightManager,
                        urgeManager: urgeManager,
                        statsManager: statsManager
                    )
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    bootstrapManager.refresh(
                        planManager: planManager,
                        checkInManager: checkInManager,
                        attributeManager: attributeManager,
                        insightManager: insightManager,
                        urgeManager: urgeManager,
                        statsManager: statsManager
                    )
                }
        }
    }
}
