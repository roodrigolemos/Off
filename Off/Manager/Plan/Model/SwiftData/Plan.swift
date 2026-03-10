//
//  Plan.swift
//  Off
//

import Foundation
import SwiftData

@Model
final class Plan {

    var firstPlanCreatedAt: Date
    var createdAt: Date

    var name: String
    var timeBoundaryRaw: String
    var timeWindowsData: [[String: Int]]
    var daysRaw: Int
    var lightSupportsRaw: [String]

    init(from snapshot: PlanSnapshot) {
        self.firstPlanCreatedAt = snapshot.firstPlanCreatedAt
        self.createdAt = snapshot.createdAt
        self.name = snapshot.name
        self.timeBoundaryRaw = snapshot.timeBoundary.rawValue
        self.timeWindowsData = snapshot.timeWindows.map { tw in
            ["sh": tw.startHour, "sm": tw.startMinute, "eh": tw.endHour, "em": tw.endMinute]
        }
        self.daysRaw = snapshot.days.rawValue
        self.lightSupportsRaw = snapshot.lightSupports.map(\.rawValue)
    }

    func toSnapshot() -> PlanSnapshot? {
        guard let timeBoundary = TimeBoundary(rawValue: timeBoundaryRaw) else {
            return nil
        }

        let windows = timeWindowsData.compactMap { dict -> TimeWindowValue? in
            guard let sh = dict["sh"], let sm = dict["sm"],
                  let eh = dict["eh"], let em = dict["em"] else { return nil }
            return TimeWindowValue(startHour: sh, startMinute: sm, endHour: eh, endMinute: em)
        }
        let normalizedWindows = PlanTimeWindowRules.normalized(timeBoundary: timeBoundary, timeWindows: windows)

        let lightSupports = Set(lightSupportsRaw.compactMap { LightSupport(rawValue: $0) })

        return PlanSnapshot(
            firstPlanCreatedAt: firstPlanCreatedAt,
            createdAt: createdAt,
            name: name,
            timeBoundary: timeBoundary,
            timeWindows: normalizedWindows,
            days: DaysOfWeek(rawValue: daysRaw),
            lightSupports: lightSupports
        )
    }
}
