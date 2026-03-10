//
//  ExpectedResultsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct ExpectedResultsView: View {

    @Environment(OnboardingManager.self) var manager
    
    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                resultsSection
                ctaSection
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Sections
private extension ExpectedResultsView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Great plan")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Text("This plan is designed to gently reduce friction and support better patterns over time.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    var resultsSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {

                // ── Time Delta Card ──
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 14))
                                .frame(width: 28, height: 28)

                            Image(systemName: "clock.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                        }

                        Text("Social time")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.offTextPrimary)

                        Spacer()
                    }

                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Now")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.offTextSecondary.opacity(0.75))

                            Text(manager.currentDailyHours)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.offTextPrimary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.offTextSecondary.opacity(0.08))
                        )

                        Image(systemName: "arrow.right")
                            .foregroundStyle(Color.offTextSecondary.opacity(0.6))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("With Off")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.offTextSecondary.opacity(0.75))

                            Text(manager.projectedDailyHours)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.offTextPrimary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.offTextSecondary.opacity(0.08))
                        )
                    }
                    .padding(.top, 2)

                    Text("That's about **\(manager.daysSavedPerYear) days a year** back — without cutting social out completely")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }
                .padding(20)
                .frame(maxWidth: 520, alignment: .leading)
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

                // ── Metrics Grid ──
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(Attribute.allCases, id: \.self) { attribute in
                        let delta = manager.projectedDelta(for: attribute)
                        let projected = manager.projectedScore(for: attribute)
                        resultTile(
                            icon: attribute.icon,
                            title: attribute.label,
                            score: projected,
                            delta: delta > 0 ? "+\(delta)" : nil,
                            description: attribute.projectedDescription(for: projected)
                        )
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 12)
            }
        }
    }

    var ctaSection: some View {
        Button(action: onNext) {
            Text("Start my plan")
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
private extension ExpectedResultsView {

    func resultTile(icon: String, title: String, score: Int, delta: String?, description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 14))
                        .frame(width: 28, height: 28)

                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                }

                Spacer()

                if let delta {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.offAccent)

                        Text(delta)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.offTextPrimary)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.offTextSecondary.opacity(0.10))
                    )
                }
            }

            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            HStack(spacing: 5) {
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(i < score ? Color.offAccent : Color.offStroke.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Text(description)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.offTextSecondary.opacity(0.70))
                .lineLimit(2)
                .minimumScaleFactor(0.95)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
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
    ExpectedResultsView(onNext: {})
        .environment(OnboardingManager())
}
