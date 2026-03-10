//
//  SwiftDataUrgeStore.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataUrgeStore: UrgeStore {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [UrgeSnapshot] {
        let descriptor = FetchDescriptor<UrgeIntervention>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { $0.toSnapshot() }
    }

    func save(_ snapshot: UrgeSnapshot) throws {
        let model = UrgeIntervention(from: snapshot)
        context.insert(model)
        try context.save()
    }
}
