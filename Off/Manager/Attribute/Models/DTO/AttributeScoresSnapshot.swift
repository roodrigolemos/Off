//
//  AttributeScoresSnapshot.swift
//  Off
//

import Foundation

struct AttributeScoresSnapshot: Equatable {
    let scores: [Attribute: Double]
    let momentum: [Attribute: Bool]
    let lastProcessedMonday: Date?
    let updatedAt: Date
}
