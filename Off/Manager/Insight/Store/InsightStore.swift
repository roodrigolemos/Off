//
//  InsightStore.swift
//  Off
//

import Foundation
import SwiftData

@MainActor
protocol InsightStore {
    func fetchAll() throws -> [InsightSnapshot]
    func fetchForWeekStart(_ date: Date) throws -> InsightSnapshot?
    func save(_ snapshot: InsightSnapshot) throws
}

