//
//  PlanAdherence.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

enum PlanAdherence: Int, CaseIterable, Codable, Hashable {
    case yes = 0
    case partially = 1
    case no = 2

    var label: String {
        switch self {
        case .yes: "Yes"
        case .partially: "Partially"
        case .no: "No"
        }
    }
}
