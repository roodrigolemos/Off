//
//  UsageProgressSnapshot.swift
//  Off
//

struct UsageProgressSnapshot {
    let state: UsageProgressState
}

enum UsageProgressState {
    case requiredScreenTimePermission
    case requiredSelection
    case usageEnabled
}
