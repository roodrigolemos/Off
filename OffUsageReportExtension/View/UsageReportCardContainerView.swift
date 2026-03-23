//
//  UsageReportCardContainerView.swift
//  OffUsageReportExtension
//

import SwiftUI

struct UsageReportCardContainerView<Content: View>: View {

    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.offSurface)

            content
                .padding(22)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.offTileStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
