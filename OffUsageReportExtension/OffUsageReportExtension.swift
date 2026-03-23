//
//  OffUsageReportExtension.swift
//  OffUsageReportExtension
//
//  Created by Rodrigo Lemos on 19/03/26.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct OffUsageReportExtension: DeviceActivityReportExtension {

    var body: some DeviceActivityReportScene {
        UsageReportScene { configuration in
            UsageReportContentView(configuration: configuration)
        }
    }
}
