//
//  WeekDayState.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

struct WeekDayState: Equatable, Identifiable {
    let id: Int
    let label: String
    let state: DayAdherenceState
}
