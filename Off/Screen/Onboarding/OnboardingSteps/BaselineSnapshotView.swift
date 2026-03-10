//
//  BaselineSnapshotView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct BaselineSnapshotView: View {

    @Environment(OnboardingManager.self) var manager

    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                usageBarSection

                ScrollView(.vertical, showsIndicators: false) {
                    metricsSection
                }

                ctaSection
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Sections

private extension BaselineSnapshotView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This is your starting point")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)

            Text("Not a grade, just where you are right now. We'll build from here.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    var usageBarSection: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 16))
                    .frame(width: 36, height: 36)

                Image(systemName: "clock.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Social media use")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)

                Text("~\(manager.currentDailyHours)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)
            }

            Spacer()

            Text("\(manager.daysPerYear)d / year")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [Color.offAccent.opacity(0.04), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    var metricsSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(Attribute.allCases, id: \.self) { attribute in
                let score = manager.baselineRatings[attribute] ?? 3
                metricTile(
                    icon: attribute.icon,
                    title: attribute.label,
                    score: score,
                    description: attribute.snapshotDescription(for: score)
                )
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 12)
    }

    var ctaSection: some View {
        Button { onNext() } label: {
            Text("Continue")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                )
                .foregroundStyle(.white)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Helper Views

private extension BaselineSnapshotView {

    func metricTile(icon: String, title: String, score: Int, description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 14))
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)

            HStack(spacing: 5) {
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(i < score ? Color.offAccent : Color.offStroke.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Text(description)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [Color.offAccent.opacity(0.04), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    BaselineSnapshotView(onNext: {})
        .environment(OnboardingManager())
}
