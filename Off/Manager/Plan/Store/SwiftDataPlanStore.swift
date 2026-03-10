//
//  SwiftDataPlanStore.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataPlanStore: PlanStore {
    
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchActivePlan() throws -> PlanSnapshot? {
        let descriptor = FetchDescriptor<Plan>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.compactMap { $0.toSnapshot() }.first
    }

    func fetchAllPlans() throws -> [PlanSnapshot] {
        let descriptor = FetchDescriptor<Plan>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let models = try context.fetch(descriptor)
        return models.compactMap { $0.toSnapshot() }
    }

    func save(_ snapshot: PlanSnapshot) throws {
        let model = Plan(from: snapshot)
        context.insert(model)
        try context.save()
    }
}
