//
//  PlanStore.swift
//  Off
//

import Foundation
import SwiftData

@MainActor
protocol PlanStore {
    func fetchActivePlan() throws -> PlanSnapshot?
    func fetchAllPlans() throws -> [PlanSnapshot]
    func save(_ snapshot: PlanSnapshot) throws
}

