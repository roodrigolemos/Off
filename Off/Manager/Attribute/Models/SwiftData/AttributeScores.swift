//
//  AttributeState.swift
//  Off
//

import Foundation
import SwiftData

@Model
final class AttributeState {
    
    var currentFocus: Double
    var currentControl: Double
    var currentAction: Double
    var currentEnergy: Double
    var baselineFocus: Double
    var baselineControl: Double
    var baselineAction: Double
    var baselineEnergy: Double
    var initializedAt: Date
    var updatedAt: Date

    init(
        currentFocus: Double,
        currentControl: Double,
        currentAction: Double,
        currentEnergy: Double,
        baselineFocus: Double,
        baselineControl: Double,
        baselineAction: Double,
        baselineEnergy: Double,
        initializedAt: Date,
        updatedAt: Date
    ) {
        self.currentFocus = currentFocus
        self.currentControl = currentControl
        self.currentAction = currentAction
        self.currentEnergy = currentEnergy
        self.baselineFocus = baselineFocus
        self.baselineControl = baselineControl
        self.baselineAction = baselineAction
        self.baselineEnergy = baselineEnergy
        self.initializedAt = initializedAt
        self.updatedAt = updatedAt
    }

    init(from snapshot: AttributeStateSnapshot) {
        self.currentFocus = snapshot.currentStates[.focus] ?? 0
        self.currentControl = snapshot.currentStates[.control] ?? 0
        self.currentAction = snapshot.currentStates[.action] ?? 0
        self.currentEnergy = snapshot.currentStates[.energy] ?? 0
        self.baselineFocus = snapshot.baselineStates[.focus] ?? 0
        self.baselineControl = snapshot.baselineStates[.control] ?? 0
        self.baselineAction = snapshot.baselineStates[.action] ?? 0
        self.baselineEnergy = snapshot.baselineStates[.energy] ?? 0
        self.initializedAt = snapshot.initializedAt
        self.updatedAt = snapshot.updatedAt
    }

    func toSnapshot() -> AttributeStateSnapshot {
        AttributeStateSnapshot(
            currentStates: [
                .focus: currentFocus,
                .control: currentControl,
                .action: currentAction,
                .energy: currentEnergy
            ],
            baselineStates: [
                .focus: baselineFocus,
                .control: baselineControl,
                .action: baselineAction,
                .energy: baselineEnergy
            ],
            initializedAt: initializedAt,
            updatedAt: updatedAt
        )
    }
}
