//
//  UrgeError.swift
//  Off
//

import Foundation

enum UrgeError: Error, LocalizedError {
    case saveFailed
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed: "Could not save your intervention."
        case .loadFailed: "Could not load interventions."
        }
    }
}
