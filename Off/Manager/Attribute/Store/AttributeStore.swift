//
//  AttributeStore.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import Foundation
import SwiftData

@MainActor
protocol AttributeStore {
    func fetchState() throws -> AttributeStateSnapshot?
    func saveState(_ snapshot: AttributeStateSnapshot) throws
}
