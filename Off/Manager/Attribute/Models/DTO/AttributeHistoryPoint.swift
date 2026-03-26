//
//  AttributeHistoryPoint.swift
//  Off
//

import Foundation

struct AttributeHistoryPoint: Identifiable, Equatable {
    let date: Date
    let stateValue: Double

    var id: Date { date }
}
