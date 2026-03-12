//
//  OnboardingManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class OnboardingManager {
    
    var baselineRatings: [Attribute: Int] = [:]
    var socialTime: String? = nil
    var planName: String = ""
    var timeBoundary: TimeBoundary = .duringWindows
    var timeWindows: [TimeWindowValue] = [PlanTimeWindowRules.defaultWindow]
    var dailyAppLimit: Int? = nil
    var days: DaysOfWeek = .everyday
    var lightSupports: Set<LightSupport> = []
    var selectedMirrorCards: Set<Int> = []

    func setBaselineRatings(_ ratings: [Attribute: Int]) {
        baselineRatings = ratings
    }

    func setSocialTime(_ time: String) {
        socialTime = time
    }

    func setPlanRules(
        name: String,
        timeBoundary: TimeBoundary,
        timeWindows: [TimeWindowValue],
        dailyAppLimit: Int,
        days: DaysOfWeek,
        lightSupports: Set<LightSupport>
    ) {
        let normalizedWindows = PlanTimeWindowRules.normalized(timeBoundary: timeBoundary, timeWindows: timeWindows)
        self.planName = name
        self.timeBoundary = timeBoundary
        self.timeWindows = normalizedWindows
        self.dailyAppLimit = dailyAppLimit
        self.days = days
        self.lightSupports = lightSupports
    }

    func setSelectedMirrorCards(_ cards: Set<Int>) {
        selectedMirrorCards = cards
    }

    var mirrorSummary: String {
        let labels: [Int: String] = [
            0: "the fatigue",
            1: "the brain fog",
            2: "the autopilot",
            3: "the restlessness",
            4: "the resistance",
            5: "the endless scrolling"
        ]
        let picked = selectedMirrorCards.sorted().prefix(2).compactMap { labels[$0] }
        guard !picked.isEmpty else { return "The fatigue, the autopilot, the restlessness" }
        return picked.enumerated().map { index, item in
            index == 0 ? item.prefix(1).uppercased() + item.dropFirst() : item
        }.joined(separator: ", ")
    }

    var baselineSummary: String {
        let phrases: [Attribute: String] = [
            .clarity: "your clarity foggy",
            .focus: "your focus low",
            .energy: "your energy drained",
            .drive: "your drive fading",
            .control: "your control slipping",
            .patience: "your patience thin"
        ]
        let worst = baselineRatings
            .sorted { $0.value < $1.value }
            .prefix(2)
            .compactMap { phrases[$0.key] }
        guard !worst.isEmpty else { return "your clarity foggy, your focus low" }
        return worst.joined(separator: ", ")
    }

    var outcomeSummary: String {
        let phrases: [Attribute: String] = [
            .clarity: "more clarity",
            .focus: "sharper focus",
            .energy: "steadier energy",
            .drive: "less resistance",
            .control: "more intention",
            .patience: "more calm"
        ]
        let worst = baselineRatings
            .sorted { $0.value < $1.value }
            .prefix(3)
            .compactMap { phrases[$0.key] }
        guard !worst.isEmpty else { return "more clarity, sharper focus, steadier energy" }
        return worst.joined(separator: ", ")
    }

    var daysPerYear: Int {
        let dailyHours: Double
        switch socialTime {
        case "Less than 1 hour": dailyHours = 0.5
        case "1–2 hours":        dailyHours = 1.5
        case "2–4 hours":        dailyHours = 3
        case "4–6 hours":        dailyHours = 5
        case "More than 6 hours": dailyHours = 7
        default:                  dailyHours = 3
        }
        return Int(round(dailyHours * 365 / 24))
    }

    var currentDailyHours: String {
        switch socialTime {
        case "Less than 1 hour":  return "30min/day"
        case "1–2 hours":         return "1.5h/day"
        case "2–4 hours":         return "3h/day"
        case "4–6 hours":         return "5h/day"
        case "More than 6 hours": return "7h/day"
        default:                  return "3h/day"
        }
    }

    var projectedDailyHours: String {
        switch socialTime {
        case "Less than 1 hour":  return "15min/day"
        case "1–2 hours":         return "1h/day"
        case "2–4 hours":         return "2h/day"
        case "4–6 hours":         return "3.5h/day"
        case "More than 6 hours": return "5.5h/day"
        default:                  return "2h/day"
        }
    }

    var daysSavedPerYear: Int {
        let currentHours: Double
        let projectedHours: Double
        switch socialTime {
        case "Less than 1 hour":  currentHours = 0.5;  projectedHours = 0.25
        case "1–2 hours":         currentHours = 1.5;  projectedHours = 1
        case "2–4 hours":         currentHours = 3;    projectedHours = 2
        case "4–6 hours":         currentHours = 5;    projectedHours = 3.5
        case "More than 6 hours": currentHours = 7;    projectedHours = 5.5
        default:                  currentHours = 3;    projectedHours = 2
        }
        return Int(round((currentHours - projectedHours) * 365 / 24))
    }

    func projectedScore(for attribute: Attribute) -> Int {
        let baseline = baselineRatings[attribute] ?? 3
        return min(baseline + projectedDelta(for: attribute), 5)
    }

    func projectedDelta(for attribute: Attribute) -> Int {
        let baseline = baselineRatings[attribute] ?? 3
        switch attribute {
        case .control:
            switch baseline {
            case 1...3: return 2
            case 4:     return 1
            default:    return 0
            }
        case .clarity, .focus:
            switch baseline {
            case 1...2: return 2
            case 3...4: return 1
            default:    return 0
            }
        case .energy, .drive, .patience:
            switch baseline {
            case 1...4: return 1
            default:    return 0
            }
        }
    }
}
