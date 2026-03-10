//
//  LightSupport.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

enum LightSupport: String, Codable, CaseIterable, Hashable {
    case notificationsOff
    case removeFromHomeScreen
    case logOut

    var displayName: String {
        switch self {
        case .notificationsOff: return "Turn off notifications"
        case .removeFromHomeScreen: return "Remove from Home Screen"
        case .logOut: return "Log out"
        }
    }
}
