//
//  PlanAppLimitRules.swift
//  Off
//

import Foundation

enum PlanAppLimitRules {
    
    static let presetLimits = [30, 60, 90, 120]

    static func isValid(limitMinutes: Int) -> Bool {
        limitMinutes > 0
    }

    static func displayText(for limitMinutes: Int) -> String {
        switch limitMinutes {
        case 30:
            return "30 min"
        case 60:
            return "1 hour"
        case 90:
            return "1 hour and 30 min"
        case 120:
            return "2 hour"
        default: return ""
        }
    }
}
