//
//  CheckInSnapshot.swift
//  Off
//

import Foundation

struct CheckInSnapshot: Identifiable, Equatable {
    
    let id: UUID
    let date: Date
    let clarity: AttributeRating
    let focus: AttributeRating
    let energy: AttributeRating
    let drive: AttributeRating
    let patience: AttributeRating
    let control: ControlRating
    let urgeLevel: UrgeLevel
    let planAdherence: PlanAdherence?
    let wasPlanDay: Bool

    init(
        id: UUID = UUID(),
        date: Date = .now,
        clarity: AttributeRating,
        focus: AttributeRating,
        energy: AttributeRating,
        drive: AttributeRating,
        patience: AttributeRating,
        control: ControlRating,
        urgeLevel: UrgeLevel,
        planAdherence: PlanAdherence?,
        wasPlanDay: Bool
    ) {
        self.id = id
        self.date = date
        self.clarity = clarity
        self.focus = focus
        self.energy = energy
        self.drive = drive
        self.patience = patience
        self.control = control
        self.urgeLevel = urgeLevel
        self.planAdherence = planAdherence
        self.wasPlanDay = wasPlanDay
    }
}

extension CheckInSnapshot {

    static let sample = CheckInSnapshot(
        date: .now,
        clarity: .better,
        focus: .same,
        energy: .better,
        drive: .same,
        patience: .worse,
        control: .conscious,
        urgeLevel: .noticeable,
        planAdherence: .yes,
        wasPlanDay: true
    )
}
