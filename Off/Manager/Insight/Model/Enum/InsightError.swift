//
//  InsightError.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation

enum InsightError: Error, LocalizedError {
    case loadFailed
    case saveFailed
    case generationFailed
    case insufficientData
    case alreadyGenerated

    var errorDescription: String? {
        switch self {
        case .loadFailed: "Could not load insights."
        case .saveFailed: "Could not save insight."
        case .generationFailed: "Could not generate your weekly insight."
        case .insufficientData: "Not enough check-ins last week to generate an insight."
        case .alreadyGenerated: "Insight already generated for this week."
        }
    }
}
