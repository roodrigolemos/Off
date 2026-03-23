//
//  UsageReportScene.swift
//  OffUsageReportExtension
//

import DeviceActivity
import ExtensionKit
import SwiftUI

struct UsageReportScene: DeviceActivityReportScene {

    let context: DeviceActivityReport.Context = .usageReport
    let content: (UsageReportConfiguration) -> UsageReportContentView

    @MainActor
    private static let reportManager = UsageReportManager(
        store: DeviceActivityUsageReportStore()
    )

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> UsageReportConfiguration {
        await Self.reportManager.makeConfiguration(from: data)
    }
}
