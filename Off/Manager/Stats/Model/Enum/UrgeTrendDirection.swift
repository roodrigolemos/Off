//
//  UrgeTrendDirection.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

enum UrgeTrendDirection: Equatable {
    case decreasing
    case increasing
    case stable
    case insufficientData

    var message: String {
        switch self {
        case .decreasing:
            return "Your urges have been easing compared to last week"
        case .increasing:
            return "Your urges have been stronger compared to last week"
        case .stable:
            return "Your urges have been steady compared to last week"
        case .insufficientData:
            return "Not enough check-ins this week to update your trend."
        }
    }
}
