//
//  AttributeError.swift
//  Off
//

import Foundation

enum AttributeError: Error, LocalizedError {
    
    case saveFailed
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed: "Could not save attribute scores."
        case .loadFailed: "Could not load attribute scores."
        }
    }
}
