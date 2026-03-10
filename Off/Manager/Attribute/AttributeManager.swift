//
//  AttributeManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class AttributeManager {
    
    private let store: AttributeStore

    var scores: AttributeScoresSnapshot?
    var error: AttributeError?

    init(store: AttributeStore) {
        self.store = store
    }

    func loadScores() {
        do {
            scores = try store.fetchScores()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func setInitialScores(ratings: [Attribute: Int]) {
        do {
            let normalized = Dictionary(uniqueKeysWithValues: Attribute.allCases.map { attribute in
                (attribute, Double(ratings[attribute] ?? 3))
            })
            let momentum = Dictionary(uniqueKeysWithValues: Attribute.allCases.map { ($0, false) })
            let snapshot = AttributeScoresSnapshot(
                scores: normalized,
                momentum: momentum,
                lastProcessedMonday: nil,
                updatedAt: .now
            )
            try store.saveScores(snapshot)
            loadScores()
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }

    func runWeeklyEvolutionIfNeeded(plan: PlanSnapshot?, checkIns: [CheckInSnapshot], now: Date = .now) {
        guard let plan, var current = scores else { return }

        let mondays = mondaysToProcess(
            from: current.lastProcessedMonday,
            planStart: plan.firstPlanCreatedAt,
            now: now
        )

        guard !mondays.isEmpty else { return }

        var observedFirstWeek = current.lastProcessedMonday != nil

        for monday in mondays {
            if !observedFirstWeek {
                current = AttributeScoresSnapshot(
                    scores: current.scores,
                    momentum: current.momentum,
                    lastProcessedMonday: monday,
                    updatedAt: now
                )
                observedFirstWeek = true
                continue
            }

            current = applyEvolution(
                to: current,
                plan: plan,
                checkIns: checkIns,
                monday: monday,
                now: now
            )
        }

        do {
            try store.saveScores(current)
            loadScores()
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }
    
    private func applyEvolution(
        to snapshot: AttributeScoresSnapshot,
        plan: PlanSnapshot,
        checkIns: [CheckInSnapshot],
        monday: Date,
        now: Date
    ) -> AttributeScoresSnapshot {
        var updatedScores = snapshot.scores
        var updatedMomentum = snapshot.momentum

        let weekCheckIns = checkInsForPreviousWeek(checkIns, monday: monday)
        guard weekCheckIns.count >= 4 else {
            return AttributeScoresSnapshot(
                scores: updatedScores,
                momentum: updatedMomentum,
                lastProcessedMonday: monday,
                updatedAt: now
            )
        }

        let adherence = adherenceClass(
            plan: plan,
            checkIns: weekCheckIns,
            monday: monday
        )

        for attribute in Attribute.allCases {
            let tendency = tendency(for: attribute, checkIns: weekCheckIns)
            let movement = movement(for: tendency, adherence: adherence)

            let previous = updatedScores[attribute] ?? 3.0
            let next = (previous + movement).clamped(to: 1.0...5.0)
            updatedScores[attribute] = next

            let wasPositive = tendency == .strongPositive || tendency == .mildPositive
            let wasNegative = tendency == .strongNegative || tendency == .mildNegative

            if wasNegative {
                updatedMomentum[attribute] = false
            } else if wasPositive, previous >= 5.0 {
                updatedMomentum[attribute] = true
            } else {
                updatedMomentum[attribute] = updatedMomentum[attribute] ?? false
            }
        }

        return AttributeScoresSnapshot(
            scores: updatedScores,
            momentum: updatedMomentum,
            lastProcessedMonday: monday,
            updatedAt: now
        )
    }

    private func mondaysToProcess(from lastProcessedMonday: Date?, planStart: Date, now: Date) -> [Date] {
        let calendar = Calendar.current
        let thisMonday = Date.thisWeekMonday(now: now)
        let firstCandidateMonday = calendar.date(
            byAdding: .day,
            value: 7,
            to: Date.thisWeekMonday(now: planStart)
        ) ?? thisMonday

        let startMonday: Date = {
            if let lastProcessedMonday {
                return calendar.date(byAdding: .day, value: 7, to: lastProcessedMonday) ?? thisMonday
            }
            return firstCandidateMonday
        }()

        guard startMonday <= thisMonday else { return [] }

        var mondays: [Date] = []
        var cursor = startMonday
        while cursor <= thisMonday {
            mondays.append(cursor)
            cursor = calendar.date(byAdding: .day, value: 7, to: cursor) ?? thisMonday.addingTimeInterval(1)
        }
        return mondays
    }

    private func checkInsForPreviousWeek(_ checkIns: [CheckInSnapshot], monday: Date) -> [CheckInSnapshot] {
        let calendar = Calendar.current
        let weekStart = calendar.date(byAdding: .day, value: -7, to: monday) ?? monday
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        let weekEndPlusOneDay = calendar.date(byAdding: .day, value: 1, to: weekEnd) ?? weekEnd

        return checkIns.filter { checkIn in
            let day = calendar.startOfDay(for: checkIn.date)
            return day >= weekStart && day < weekEndPlusOneDay
        }
    }

    private func tendency(for attribute: Attribute, checkIns: [CheckInSnapshot]) -> Tendency {
        var better = 0
        var worse = 0

        for checkIn in checkIns {
            let value: Int = switch attribute {
            case .clarity: checkIn.clarity.rawValue
            case .focus: checkIn.focus.rawValue
            case .energy: checkIn.energy.rawValue
            case .drive: checkIn.drive.rawValue
            case .control: checkIn.control.rawValue
            case .patience: checkIn.patience.rawValue
            }

            if value > 0 { better += 1 }
            if value < 0 { worse += 1 }
        }

        let delta = better - worse
        switch delta {
        case 3...: return .strongPositive
        case 1...2: return .mildPositive
        case 0: return .neutral
        case -2 ... -1: return .mildNegative
        default: return .strongNegative
        }
    }

    private func adherenceClass(plan: PlanSnapshot, checkIns: [CheckInSnapshot], monday: Date) -> AdherenceClass {
        let calendar = Calendar.current
        let weekStart = calendar.date(byAdding: .day, value: -7, to: monday) ?? monday
        let planStart = calendar.startOfDay(for: plan.firstPlanCreatedAt)

        var byDay: [Date: CheckInSnapshot] = [:]
        for checkIn in checkIns {
            byDay[calendar.startOfDay(for: checkIn.date)] = checkIn
        }

        var yesCount = 0
        var noCount = 0
        var partiallyCount = 0

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart) else { continue }
            let dayStart = calendar.startOfDay(for: day)

            guard dayStart >= planStart, plan.days.contains(date: dayStart) else {
                continue
            }

            guard let checkIn = byDay[dayStart] else {
                noCount += 1
                continue
            }

            switch checkIn.planAdherence ?? .no {
            case .yes:
                yesCount += 1
            case .partially:
                partiallyCount += 1
            case .no:
                noCount += 1
            }
        }

        if yesCount > noCount && yesCount > partiallyCount {
            return .high
        }
        if noCount > yesCount && noCount > partiallyCount {
            return .low
        }
        return .medium
    }

    private func movement(for tendency: Tendency, adherence: AdherenceClass) -> Double {
        switch tendency {
        case .strongPositive:
            switch adherence {
            case .high: return 1.0
            case .medium: return 0.5
            case .low: return 0.0
            }
        case .mildPositive:
            switch adherence {
            case .high, .medium: return 0.5
            case .low: return 0.0
            }
        case .neutral:
            return 0.0
        case .mildNegative:
            return -0.5
        case .strongNegative:
            return -1.0
        }
    }
}
