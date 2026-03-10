//
//  AttributeScores.swift
//  Off
//

import Foundation
import SwiftData

@Model
final class AttributeScores {
    
    var clarity: Double
    var focus: Double
    var energy: Double
    var drive: Double
    var control: Double
    var patience: Double
    var clarityMomentum: Bool
    var focusMomentum: Bool
    var energyMomentum: Bool
    var driveMomentum: Bool
    var controlMomentum: Bool
    var patienceMomentum: Bool
    var lastProcessedMonday: Date?
    var updatedAt: Date

    init(
        clarity: Double,
        focus: Double,
        energy: Double,
        drive: Double,
        control: Double,
        patience: Double,
        clarityMomentum: Bool,
        focusMomentum: Bool,
        energyMomentum: Bool,
        driveMomentum: Bool,
        controlMomentum: Bool,
        patienceMomentum: Bool,
        lastProcessedMonday: Date?,
        updatedAt: Date
    ) {
        self.clarity = clarity
        self.focus = focus
        self.energy = energy
        self.drive = drive
        self.control = control
        self.patience = patience
        self.clarityMomentum = clarityMomentum
        self.focusMomentum = focusMomentum
        self.energyMomentum = energyMomentum
        self.driveMomentum = driveMomentum
        self.controlMomentum = controlMomentum
        self.patienceMomentum = patienceMomentum
        self.lastProcessedMonday = lastProcessedMonday
        self.updatedAt = updatedAt
    }

    init(from snapshot: AttributeScoresSnapshot) {
        self.clarity = snapshot.scores[.clarity] ?? 3
        self.focus = snapshot.scores[.focus] ?? 3
        self.energy = snapshot.scores[.energy] ?? 3
        self.drive = snapshot.scores[.drive] ?? 3
        self.control = snapshot.scores[.control] ?? 3
        self.patience = snapshot.scores[.patience] ?? 3
        self.clarityMomentum = snapshot.momentum[.clarity] ?? false
        self.focusMomentum = snapshot.momentum[.focus] ?? false
        self.energyMomentum = snapshot.momentum[.energy] ?? false
        self.driveMomentum = snapshot.momentum[.drive] ?? false
        self.controlMomentum = snapshot.momentum[.control] ?? false
        self.patienceMomentum = snapshot.momentum[.patience] ?? false
        self.lastProcessedMonday = snapshot.lastProcessedMonday
        self.updatedAt = snapshot.updatedAt
    }

    func toSnapshot() -> AttributeScoresSnapshot {
        AttributeScoresSnapshot(
            scores: [
                .clarity: clarity,
                .focus: focus,
                .energy: energy,
                .drive: drive,
                .control: control,
                .patience: patience
            ],
            momentum: [
                .clarity: clarityMomentum,
                .focus: focusMomentum,
                .energy: energyMomentum,
                .drive: driveMomentum,
                .control: controlMomentum,
                .patience: patienceMomentum
            ],
            lastProcessedMonday: lastProcessedMonday,
            updatedAt: updatedAt
        )
    }
}
