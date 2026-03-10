//
//  UrgeManager.swift
//  Off
//

import Foundation
import Observation

@MainActor
@Observable
final class UrgeManager {

    private let store: UrgeStore
    
    private(set) var activeSession: InterventionSessionBuilder?
    
    var interventions: [UrgeSnapshot] = []
    var error: UrgeError?

    init(store: UrgeStore) {
        self.store = store
    }

    func loadInterventions() {
        do {
            interventions = try store.fetchAll()
            error = nil
        } catch {
            self.error = .loadFailed
        }
    }

    // MARK: - Session Lifecycle

    func startSession() {
        activeSession = InterventionSessionBuilder(
            id: UUID(),
            timestamp: .now
        )
    }

    func setPredictedFeeling(_ feeling: PredictedFeeling) {
        activeSession?.predictedFeeling = feeling
        activeSession?.advanceTo(1)
    }

    func setSeekingWhat(_ reason: UrgeReason) {
        activeSession?.seekingWhat = reason
        activeSession?.advanceTo(2)
    }

    func setMemoryOfSuccess(_ memory: MemoryOfSuccess) {
        activeSession?.memoryOfSuccess = memory
        activeSession?.advanceTo(3)
    }

    func advanceScreen(_ screen: Int) {
        activeSession?.advanceTo(screen)
    }

    func completeSession(finalChoice: FinalChoice) {
        guard var session = activeSession else { return }
        session.finalChoice = finalChoice
        session.advanceTo(6)

        let snapshot = session.buildSnapshot(completedFull: true)
        do {
            try store.save(snapshot)
            loadInterventions()
            error = nil
        } catch {
            self.error = .saveFailed
        }

        activeSession = nil
    }

    func abandonSession() {
        guard let session = activeSession else { return }

        if session.screenReached > 0 {
            let snapshot = session.buildSnapshot(completedFull: false)
            do {
                try store.save(snapshot)
                loadInterventions()
                error = nil
            } catch {
                self.error = .saveFailed
            }
        }

        activeSession = nil
    }
}
