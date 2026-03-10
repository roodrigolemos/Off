//
//  CheckInStore.swift
//  Off
//

import Foundation
import SwiftData

@MainActor
protocol CheckInStore {
    func fetchAll() throws -> [CheckInSnapshot]
    func save(_ snapshot: CheckInSnapshot) throws
}
