//
//  OnboardingView.swift
//  Off
//
//  Created by Rodrigo Lemos on 12/02/26.
//

import SwiftUI

enum OnboardingStep {
    case welcome
    case mirrorState
    case reframeIntro
    case reframeHope
    case value
    case baselineAssessment
    case socialTime
    case impactLoading
    case socialImpact
    case baselineSnapshot
    case planRules
    case screenTimePermission
    case screenTimeApps
    case expectedResults
    case reviewRequest
    case paywall
}

struct OnboardingView: View {

    @Environment(AppState.self) var appState
    @Environment(OnboardingManager.self) var onboardingManager
    @Environment(AttributeManager.self) var attributeManager
    @Environment(PlanManager.self) var planManager
    @Environment(ScreenTimeManager.self) var screenTimeManager

    @State private var currentStep: OnboardingStep = .welcome

    var body: some View {
        ZStack {
            switch currentStep {
            case .welcome:
                WelcomeView(onNext: { currentStep = .mirrorState })
            case .mirrorState:
                MirrorStateView(onNext: { currentStep = .reframeIntro })
            case .reframeIntro:
                ReframeIntroView(onNext: { currentStep = .reframeHope })
            case .reframeHope:
                ReframeHopeView(onNext: { currentStep = .value })
            case .value:
                ValueView(onNext: { currentStep = .baselineAssessment })
            case .baselineAssessment:
                BaselineAssessmentView(onNext: { currentStep = .socialTime })
            case .socialTime:
                SocialTimeView(onNext: { currentStep = .impactLoading })
            case .impactLoading:
                ImpactLoadingView(onNext: { currentStep = .socialImpact })
            case .socialImpact:
                SocialImpactView(onNext: { currentStep = .baselineSnapshot })
            case .baselineSnapshot:
                BaselineSnapshotView(onNext: { currentStep = .planRules })
            case .planRules:
                PlanRulesView(onNext: { currentStep = .expectedResults })
            case .expectedResults:
                ExpectedResultsView(onNext: { currentStep = .screenTimePermission })
            case .screenTimePermission:
                ScreenTimePermissionView(onNext: { currentStep = .screenTimeApps })
            case .screenTimeApps:
                ScreenTimeAppsView(onNext: { currentStep = .reviewRequest })
            case .reviewRequest:
                ReviewRequestView(onNext: { currentStep = .paywall })
            case .paywall:
                PaywallView(
                    onNext: { completeOnboarding() },
                    daysPerYear: onboardingManager.daysPerYear,
                    outcomeSummary: onboardingManager.outcomeSummary
                )
            }
        }
        .animation(.smooth, value: currentStep)
    }

    private func completeOnboarding() {
        attributeManager.setInitialScores(ratings: onboardingManager.baselineRatings)
        
        let windows = PlanTimeWindowRules.normalized(
            timeBoundary: onboardingManager.timeBoundary,
            timeWindows: onboardingManager.timeWindows
        )
        planManager.createPlan(
            name: onboardingManager.planName,
            timeBoundary: onboardingManager.timeBoundary,
            timeWindows: windows,
            dailyAppLimit: onboardingManager.dailyAppLimit,
            days: onboardingManager.days,
            lightSupports: onboardingManager.lightSupports
        )
        
        screenTimeManager.saveActiveDays(days: onboardingManager.days.selectedDays)
        screenTimeManager.updateSelection(onboardingManager.activitySelection)
        
        screenTimeManager.startMonitoring(rangeStart: DateComponents(hour: onboardingManager.timeWindows.first?.startHour, minute: onboardingManager.timeWindows.first?.startMinute),
                                          rangeEnd: DateComponents(hour: onboardingManager.timeWindows.first?.endHour, minute: onboardingManager.timeWindows.first?.endMinute),
                                          limitMinutes: onboardingManager.dailyAppLimit)

        appState.updateViewState(showTabBarView: true)
    }
}

#Preview {
    OnboardingView()
        .withPreviewManagers()
}
