//
//  UrgeInsightsSnapshot.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

struct UrgeInsightsSnapshot: Equatable {
    let trendDirection: UrgeTrendDirection
    let urgeAdherenceMessage: String?

    var trendDirectionMessage: String {
        trendDirection.message
    }
}
