//
//  CheckIn.swift
//  Off
//

import Foundation
import SwiftData

@Model
final class CheckIn {

    var id: UUID
    var date: Date
    var focusRaw: Int
    var controlRaw: Int
    var actionRaw: Int
    var energyRaw: Int
    var urgeLevelRaw: Int
    var planAdherenceRaw: Int?
    var wasPlanDayRaw: Bool

    init(from snapshot: CheckInSnapshot) {
        self.id = snapshot.id
        self.date = snapshot.date
        self.focusRaw = snapshot.focus.rawValue
        self.controlRaw = snapshot.control.rawValue
        self.actionRaw = snapshot.action.rawValue
        self.energyRaw = snapshot.energy.rawValue
        self.urgeLevelRaw = snapshot.urgeLevel.rawValue
        self.planAdherenceRaw = snapshot.planAdherence?.rawValue
        self.wasPlanDayRaw = snapshot.wasPlanDay
    }

    func toSnapshot() -> CheckInSnapshot {
        CheckInSnapshot(
            id: id,
            date: date,
            focus: AttributeRating(rawValue: focusRaw) ?? .same,
            control: ControlRating(rawValue: controlRaw) ?? .same,
            action: AttributeRating(rawValue: actionRaw) ?? .same,
            energy: AttributeRating(rawValue: energyRaw) ?? .same,
            urgeLevel: UrgeLevel(rawValue: urgeLevelRaw) ?? .none,
            planAdherence: planAdherenceRaw.flatMap { PlanAdherence(rawValue: $0) },
            wasPlanDay: wasPlanDayRaw
        )
    }
}
