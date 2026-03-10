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
    var clarityRaw: Int
    var focusRaw: Int
    var energyRaw: Int
    var driveRaw: Int
    var patienceRaw: Int
    var controlRaw: Int
    var urgeLevelRaw: Int
    var planAdherenceRaw: Int?
    var wasPlanDayRaw: Bool

    init(from snapshot: CheckInSnapshot) {
        self.id = snapshot.id
        self.date = snapshot.date
        self.clarityRaw = snapshot.clarity.rawValue
        self.focusRaw = snapshot.focus.rawValue
        self.energyRaw = snapshot.energy.rawValue
        self.driveRaw = snapshot.drive.rawValue
        self.patienceRaw = snapshot.patience.rawValue
        self.controlRaw = snapshot.control.rawValue
        self.urgeLevelRaw = snapshot.urgeLevel.rawValue
        self.planAdherenceRaw = snapshot.planAdherence?.rawValue
        self.wasPlanDayRaw = snapshot.wasPlanDay
    }

    func toSnapshot() -> CheckInSnapshot {
        CheckInSnapshot(
            id: id,
            date: date,
            clarity: AttributeRating(rawValue: clarityRaw) ?? .same,
            focus: AttributeRating(rawValue: focusRaw) ?? .same,
            energy: AttributeRating(rawValue: energyRaw) ?? .same,
            drive: AttributeRating(rawValue: driveRaw) ?? .same,
            patience: AttributeRating(rawValue: patienceRaw) ?? .same,
            control: ControlRating(rawValue: controlRaw) ?? .same,
            urgeLevel: UrgeLevel(rawValue: urgeLevelRaw) ?? .none,
            planAdherence: planAdherenceRaw.flatMap { PlanAdherence(rawValue: $0) },
            wasPlanDay: wasPlanDayRaw
        )
    }
}
