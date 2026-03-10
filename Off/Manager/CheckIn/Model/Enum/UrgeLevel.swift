//
//  UrgeLevel.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

enum UrgeLevel: Int, CaseIterable, Codable, Hashable {
    case none = 0
    case noticeable = 1
    case persistent = 2
    case tookOver = 3

    var label: String {
        switch self {
        case .none: "None"
        case .noticeable: "Noticeable"
        case .persistent: "Persistent"
        case .tookOver: "Took over"
        }
    }
}
