//
//  AdherenceMonth.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

struct AdherenceMonth: Identifiable, Equatable {
    let id: String
    let displayName: String
    let cells: [AdherenceDayCell]
    let numerator: Int
    let denominator: Int
    let percentage: Int
}
