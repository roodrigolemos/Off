//
//  AdherenceDayCell.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation

struct AdherenceDayCell: Identifiable, Equatable {
    let id: String
    let date: Date?
    let state: AdherenceCellState
}
