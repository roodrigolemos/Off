//
//  DaysOfWeek.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation

struct DaysOfWeek: OptionSet, Codable, Hashable {
    let rawValue: Int

    static let sunday    = DaysOfWeek(rawValue: 1 << 0)
    static let monday    = DaysOfWeek(rawValue: 1 << 1)
    static let tuesday   = DaysOfWeek(rawValue: 1 << 2)
    static let wednesday = DaysOfWeek(rawValue: 1 << 3)
    static let thursday  = DaysOfWeek(rawValue: 1 << 4)
    static let friday    = DaysOfWeek(rawValue: 1 << 5)
    static let saturday  = DaysOfWeek(rawValue: 1 << 6)

    static let weekdays: DaysOfWeek = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let weekends: DaysOfWeek = [.saturday, .sunday]
    static let everyday: DaysOfWeek = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    
    func contains(date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        let dayMap: [Int: DaysOfWeek] = [
            1: .sunday, 2: .monday, 3: .tuesday,
            4: .wednesday, 5: .thursday, 6: .friday, 7: .saturday
        ]
        guard let day = dayMap[weekday] else { return false }
        return self.contains(day)
    }

    var dayCount: Int {
        var count = 0
        if contains(.sunday) { count += 1 }
        if contains(.monday) { count += 1 }
        if contains(.tuesday) { count += 1 }
        if contains(.wednesday) { count += 1 }
        if contains(.thursday) { count += 1 }
        if contains(.friday) { count += 1 }
        if contains(.saturday) { count += 1 }
        return count
    }
}
