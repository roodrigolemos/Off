//
//  CheckInSnapshot.swift
//  Off
//

import Foundation

struct CheckInSnapshot: Identifiable, Equatable {
    
    let id: UUID
    let date: Date
    let focus: AttributeRating
    let control: ControlRating
    let action: AttributeRating
    let energy: AttributeRating
    let urgeLevel: UrgeLevel
    let planAdherence: PlanAdherence?
    let wasPlanDay: Bool

    init(
        id: UUID = UUID(),
        date: Date = .now,
        focus: AttributeRating,
        control: ControlRating,
        action: AttributeRating,
        energy: AttributeRating,
        urgeLevel: UrgeLevel,
        planAdherence: PlanAdherence?,
        wasPlanDay: Bool
    ) {
        self.id = id
        self.date = date
        self.focus = focus
        self.control = control
        self.action = action
        self.energy = energy
        self.urgeLevel = urgeLevel
        self.planAdherence = planAdherence
        self.wasPlanDay = wasPlanDay
    }
}

extension CheckInSnapshot {

    static let sample = CheckInSnapshot(
        date: .now,
        focus: .same,
        control: .conscious,
        action: .same,
        energy: .better,
        urgeLevel: .noticeable,
        planAdherence: .yes,
        wasPlanDay: true
    )
}
