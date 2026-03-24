//
//  AttributeStateSnapshot.swift
//  Off
//

import Foundation

struct AttributeStateSnapshot: Equatable {
    let currentStates: [Attribute: Double]
    let baselineStates: [Attribute: Double]
    let initializedAt: Date
    let updatedAt: Date
}
