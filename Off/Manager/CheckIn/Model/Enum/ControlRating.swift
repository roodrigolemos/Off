//
//  ControlRating.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

enum ControlRating: Int, CaseIterable, Codable, Hashable {
    case automatic = -1
    case same = 0
    case conscious = 1

    var label: String {
        switch self {
        case .automatic: "Automatic"
        case .same: "Same"
        case .conscious: "Conscious"
        }
    }
}
