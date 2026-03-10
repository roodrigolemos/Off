//
//  SwiftDataInsightStore.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataInsightStore: InsightStore {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [InsightSnapshot] {
        let descriptor = FetchDescriptor<WeeklyInsight>(
            sortBy: [SortDescriptor(\.weekStartDate, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { $0.toSnapshot() }
    }

    func fetchForWeekStart(_ date: Date) throws -> InsightSnapshot? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        var descriptor = FetchDescriptor<WeeklyInsight>(
            predicate: #Predicate<WeeklyInsight> { insight in
                insight.weekStartDate >= startOfDay && insight.weekStartDate < endOfDay
            }
        )
        descriptor.fetchLimit = 1
        let models = try context.fetch(descriptor)
        return models.first?.toSnapshot()
    }

    func save(_ snapshot: InsightSnapshot) throws {
        let model = WeeklyInsight(from: snapshot)
        context.insert(model)
        try context.save()
    }
}
