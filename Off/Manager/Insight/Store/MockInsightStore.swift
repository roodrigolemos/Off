//
//  MockInsightStore.swift
//  Off
//

import Foundation

@MainActor
final class MockInsightStore: InsightStore {

    func fetchAll() throws -> [InsightSnapshot] {
        [InsightSnapshot.sample]
    }

    func fetchForWeekStart(_ date: Date) throws -> InsightSnapshot? {
        nil
    }

    func save(_ snapshot: InsightSnapshot) throws { }
}
