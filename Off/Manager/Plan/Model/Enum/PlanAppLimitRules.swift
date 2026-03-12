//
//  PlanAppLimitRules.swift
//  Off
//

import Foundation

enum PlanAppLimitRules {
    
    static let presetLimits = [2, 30, 60, 120]

    static func isValid(limitMinutes: Int) -> Bool {
        limitMinutes > 0
    }

    static func displayText(for limitMinutes: Int) -> String {
        switch limitMinutes {
        case 60:
            return "1 hour"
        case let minutes where minutes % 60 == 0:
            return "\(minutes / 60) hours"
        default:
            return "\(limitMinutes) min"
        }
    }
}
