//
//  WeekDayCardData.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

struct WeekDayCardData: Identifiable, Equatable {
    let id: Int
    let dayLabel: String
    let dateNumber: String
    let isToday: Bool
    let checkIn: CheckInSnapshot?
}
