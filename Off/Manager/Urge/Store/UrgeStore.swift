//
//  UrgeStore.swift
//  Off
//

import Foundation
import SwiftData

@MainActor
protocol UrgeStore {
    func fetchAll() throws -> [UrgeSnapshot]
    func save(_ snapshot: UrgeSnapshot) throws
}
