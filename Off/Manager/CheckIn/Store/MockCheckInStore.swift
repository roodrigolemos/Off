//
//  MockCheckInStore.swift
//  Off
//

import Foundation

@MainActor
final class MockCheckInStore: CheckInStore {

    func fetchAll() throws -> [CheckInSnapshot] {
        let calendar = Calendar.current
        // Skip daysAgo == 3 to create a missed day gap
        let daysToGenerate = [1, 2, 4, 5]
        return daysToGenerate.compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: .now) else { return nil }

            let adherence: PlanAdherence? = switch daysAgo {
            case 2: .partially
            case 4: .no
            case 5: nil
            default: .yes
            }
            let wasPlanDay = daysAgo != 5

            let snapshot: CheckInSnapshot = switch daysAgo {
            case 1:
                CheckInSnapshot(
                    date: date, clarity: .better, focus: .better,
                    energy: .same, drive: .better, patience: .better,
                    control: .conscious, urgeLevel: .noticeable, planAdherence: adherence, wasPlanDay: wasPlanDay
                )
            case 2:
                CheckInSnapshot(
                    date: date, clarity: .same, focus: .worse,
                    energy: .better, drive: .same, patience: .same,
                    control: .same, urgeLevel: .none, planAdherence: adherence, wasPlanDay: wasPlanDay
                )
            case 4:
                CheckInSnapshot(
                    date: date, clarity: .worse, focus: .same,
                    energy: .worse, drive: .worse, patience: .same,
                    control: .automatic, urgeLevel: .persistent, planAdherence: adherence, wasPlanDay: wasPlanDay
                )
            default:
                CheckInSnapshot(
                    date: date, clarity: .better, focus: .better,
                    energy: .better, drive: .better, patience: .better,
                    control: .conscious, urgeLevel: .none, planAdherence: adherence, wasPlanDay: wasPlanDay
                )
            }

            return snapshot
        }
    }

    func save(_ snapshot: CheckInSnapshot) throws { }
}
