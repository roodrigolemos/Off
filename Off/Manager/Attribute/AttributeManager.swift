//
//  AttributeManager.swift
//  Off
//

import Foundation
import Observation

enum AttributeMicroTrend: Equatable {
    case improving
    case stable
    case declining
}

@MainActor
@Observable
final class AttributeManager {

    private let store: AttributeStore
    private let dailyDecay: Double = 0.2
    private let stateRange: ClosedRange<Double> = -5.0...5.0
    private var latestCheckIns: [CheckInSnapshot] = []

    var snapshot: AttributeStateSnapshot?
    var error: AttributeError?

    init(store: AttributeStore) {
        self.store = store
    }

    func loadState() {
        do {
            snapshot = try store.fetchState()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    func initializeState(ratings: [Attribute: Int], now: Date = .now) {
        do {
            let baselineStates = Dictionary(uniqueKeysWithValues: Attribute.allCases.map { attribute in
                (attribute, baselineState(for: ratings[attribute] ?? 3))
            })

            let snapshot = AttributeStateSnapshot(
                currentStates: baselineStates,
                baselineStates: baselineStates,
                initializedAt: now,
                updatedAt: now
            )

            try store.saveState(snapshot)
            self.snapshot = snapshot
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }

    func refreshState(checkIns: [CheckInSnapshot], now: Date = .now) {
        guard let snapshot else { return }
        latestCheckIns = checkIns

        let refreshedSnapshot = recomputedSnapshot(from: snapshot, checkIns: checkIns, now: now)

        do {
            try store.saveState(refreshedSnapshot)
            self.snapshot = refreshedSnapshot
            error = nil
        } catch {
            self.error = .saveFailed
        }
    }

    func dotCount(for attribute: Attribute) -> Int {
        dotCount(forState: snapshot?.currentStates[attribute] ?? 0)
    }

    func microTrend(for attribute: Attribute, now: Date = .now) -> AttributeMicroTrend {
        guard let snapshot else { return .stable }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return .stable
        }

        let initializedDay = calendar.startOfDay(for: snapshot.initializedAt)
        guard initializedDay <= yesterday else {
            return .stable
        }

        let todayStates = computedStates(from: snapshot, checkIns: latestCheckIns, through: today)
        let yesterdayStates = computedStates(from: snapshot, checkIns: latestCheckIns, through: yesterday)

        let todayDotCount = dotCount(forState: todayStates[attribute] ?? 0)
        let yesterdayDotCount = dotCount(forState: yesterdayStates[attribute] ?? 0)

        if todayDotCount > yesterdayDotCount { return .improving }
        if todayDotCount < yesterdayDotCount { return .declining }
        return .stable
    }

    func stateLabel(for attribute: Attribute) -> String {
        switch dotCount(for: attribute) {
        case 5:
            return "Very high lately"
        case 4:
            return "High lately"
        case 3:
            return "Okay lately"
        case 2:
            return "Low lately"
        default:
            return "Very low lately"
        }
    }

    private func recomputedSnapshot(
        from snapshot: AttributeStateSnapshot,
        checkIns: [CheckInSnapshot],
        now: Date
    ) -> AttributeStateSnapshot {
        let currentStates = computedStates(from: snapshot, checkIns: checkIns, through: now)

        return AttributeStateSnapshot(
            currentStates: currentStates,
            baselineStates: snapshot.baselineStates,
            initializedAt: snapshot.initializedAt,
            updatedAt: now
        )
    }

    private func computedStates(
        from snapshot: AttributeStateSnapshot,
        checkIns: [CheckInSnapshot],
        through targetDate: Date
    ) -> [Attribute: Double] {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: snapshot.initializedAt)
        let endDay = calendar.startOfDay(for: targetDate)
        let latestCheckInsByDay = latestCheckInsByDay(from: checkIns, initializedAt: snapshot.initializedAt)

        guard endDay >= startDay else { return snapshot.baselineStates }

        var currentStates = snapshot.baselineStates
        var day = startDay
        var isFirstDay = true

        // Recompute from the onboarding baseline so decay and daily updates are applied exactly once per day.
        while day <= endDay {
            if !isFirstDay || latestCheckInsByDay[day] != nil {
                let dayCheckIn = latestCheckInsByDay[day]

                for attribute in Attribute.allCases {
                    let previousState = currentStates[attribute] ?? 0
                    let input = inputValue(for: attribute, checkIn: dayCheckIn)
                    currentStates[attribute] = nextState(from: previousState, input: input)
                }
            }

            isFirstDay = false
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }

        return currentStates
    }

    private func latestCheckInsByDay(
        from checkIns: [CheckInSnapshot],
        initializedAt: Date
    ) -> [Date: CheckInSnapshot] {
        let calendar = Calendar.current
        var groupedCheckIns: [Date: CheckInSnapshot] = [:]

        // When a day is edited more than once, only the latest check-in should affect that day's state.
        for checkIn in checkIns where checkIn.date >= initializedAt {
            let day = calendar.startOfDay(for: checkIn.date)
            let existing = groupedCheckIns[day]

            if existing == nil || checkIn.date > existing?.date ?? .distantPast {
                groupedCheckIns[day] = checkIn
            }
        }

        return groupedCheckIns
    }

    private func inputValue(for attribute: Attribute, checkIn: CheckInSnapshot?) -> Double {
        guard let checkIn else { return 0 }

        switch attribute {
        case .energy:
            return Double(checkIn.energy.rawValue)
        case .focus:
            return Double(checkIn.focus.rawValue)
        case .action:
            return Double(checkIn.action.rawValue)
        case .control:
            return Double(checkIn.control.rawValue)
        }
    }

    private func nextState(from previousState: Double, input: Double) -> Double {
        (previousState + input - (dailyDecay * sign(of: previousState))).clamped(to: stateRange)
    }

    private func dotCount(forState state: Double) -> Int {
        switch state {
        case ...(-3.0):
            return 1
        case -3.0..<(-1.0):
            return 2
        case -1.0...1.0:
            return 3
        case 1.0..<3.0:
            return 4
        default:
            return 5
        }
    }

    private func sign(of value: Double) -> Double {
        if value > 0 { return 1 }
        if value < 0 { return -1 }
        return 0
    }

    private func baselineState(for rating: Int) -> Double {
        switch rating.clamped(to: 1...5) {
        case 1:
            return -4
        case 2:
            return -2
        case 3:
            return 0
        case 4:
            return 2
        default:
            return 4
        }
    }
}
