//
//  ScreenTimeError.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation

enum ScreenTimeError: Error, LocalizedError {
    case requestFailed
    case loadSelectedActivitiesFailed
    case saveSelectedActivitiesFailed

    var errorDescription: String? {
        switch self {
        case .requestFailed:
            return "Could not request Screen Time permission."
        case .loadSelectedActivitiesFailed:
            return "Could not load your selected apps."
        case .saveSelectedActivitiesFailed:
            return "Could not save your selected apps."
        }
    }
}
