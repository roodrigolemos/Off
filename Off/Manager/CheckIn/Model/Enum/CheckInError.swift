//
//  CheckInError.swift
//  Off
//

import Foundation

enum CheckInError: Error, LocalizedError {
    case saveFailed
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed: "Could not save your check-in."
        case .loadFailed: "Could not load check-ins."
        }
    }
}
