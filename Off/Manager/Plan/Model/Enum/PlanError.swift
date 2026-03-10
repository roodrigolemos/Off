//
//  PlanError.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation

enum PlanError: Error, LocalizedError {
    case saveFailed
    case loadFailed
    case invalidPlanName
    case notEnoughDays
    case noActivePlan

    var errorDescription: String? {
        switch self {
        case .saveFailed: "Could not save your plan."
        case .loadFailed: "Could not load your plan."
        case .invalidPlanName: "Please enter a name for your plan."
        case .notEnoughDays: "Please select at least 4 days."
        case .noActivePlan: "No active plan found."
        }
    }
}
