//
//  AttributeScores.swift
//  Off
//

import Foundation
import SwiftData

@Model
final class AttributeScores {
    
    var focus: Double
    var control: Double
    var action: Double
    var energy: Double
    var focusMomentum: Bool
    var controlMomentum: Bool
    var actionMomentum: Bool
    var energyMomentum: Bool
    var lastProcessedMonday: Date?
    var updatedAt: Date

    init(
        focus: Double,
        control: Double,
        action: Double,
        energy: Double,
        focusMomentum: Bool,
        controlMomentum: Bool,
        actionMomentum: Bool,
        energyMomentum: Bool,
        lastProcessedMonday: Date?,
        updatedAt: Date
    ) {
        self.focus = focus
        self.control = control
        self.action = action
        self.energy = energy
        self.focusMomentum = focusMomentum
        self.controlMomentum = controlMomentum
        self.actionMomentum = actionMomentum
        self.energyMomentum = energyMomentum
        self.lastProcessedMonday = lastProcessedMonday
        self.updatedAt = updatedAt
    }

    init(from snapshot: AttributeScoresSnapshot) {
        self.focus = snapshot.scores[.focus] ?? 3
        self.control = snapshot.scores[.control] ?? 3
        self.action = snapshot.scores[.action] ?? 3
        self.energy = snapshot.scores[.energy] ?? 3
        self.focusMomentum = snapshot.momentum[.focus] ?? false
        self.controlMomentum = snapshot.momentum[.control] ?? false
        self.actionMomentum = snapshot.momentum[.action] ?? false
        self.energyMomentum = snapshot.momentum[.energy] ?? false
        self.lastProcessedMonday = snapshot.lastProcessedMonday
        self.updatedAt = snapshot.updatedAt
    }

    func toSnapshot() -> AttributeScoresSnapshot {
        AttributeScoresSnapshot(
            scores: [
                .focus: focus,
                .control: control,
                .action: action,
                .energy: energy
            ],
            momentum: [
                .focus: focusMomentum,
                .control: controlMomentum,
                .action: actionMomentum,
                .energy: energyMomentum
            ],
            lastProcessedMonday: lastProcessedMonday,
            updatedAt: updatedAt
        )
    }
}
