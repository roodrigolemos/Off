//
//  AttributeRating.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

enum AttributeRating: Int, CaseIterable, Codable, Hashable {
    case worse = -1
    case same = 0
    case better = 1

    var label: String {
        switch self {
        case .worse: "Worse"
        case .same: "Same"
        case .better: "Better"
        }
    }
}
