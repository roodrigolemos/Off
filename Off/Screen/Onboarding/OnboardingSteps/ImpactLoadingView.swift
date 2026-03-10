//
//  ImpactLoadingView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct ImpactLoadingView: View {

    var onNext: () -> Void

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                contentSection
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .task {
            isAnimating = true
            try? await Task.sleep(for: .seconds(3))
            onNext()
        }
    }
}

// MARK: - Sections
private extension ImpactLoadingView {

    var contentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Thinking")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .opacity(isAnimating ? 1.0 : 0.6)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)

            Text("Understanding how this affects you...")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .lineLimit(2)
                .minimumScaleFactor(0.95)
        }
        .frame(maxWidth: 520, alignment: .leading)
    }
}

#Preview {
    ImpactLoadingView(onNext: {})
}
