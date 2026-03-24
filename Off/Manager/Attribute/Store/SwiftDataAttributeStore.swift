//
//  SwiftDataAttributeStore.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataAttributeStore: AttributeStore {
    
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchState() throws -> AttributeStateSnapshot? {
        let descriptor = FetchDescriptor<AttributeState>()
        let models = try context.fetch(descriptor)
        return models.first?.toSnapshot()
    }

    func saveState(_ snapshot: AttributeStateSnapshot) throws {
        let descriptor = FetchDescriptor<AttributeState>()
        let existingStates = try context.fetch(descriptor)
        for model in existingStates {
            context.delete(model)
        }
        let state = AttributeState(from: snapshot)
        context.insert(state)
        try context.save()
    }
}
