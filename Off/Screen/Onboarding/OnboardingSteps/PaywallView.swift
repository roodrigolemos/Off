//
//  PaywallView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct PaywallView: View {

    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var hasAppeared: Bool = false
    @State private var scrollOffset: CGFloat = 0

    var onNext: () -> Void

    var daysPerYear: Int
    var outcomeSummary: String

    enum SubscriptionPlan { case yearly, weekly }

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack {
                heroSection
                    .padding(.horizontal, 18)
                    .padding(.top, 60)
                Spacer().frame(height: 24)
                benefitSection
                    .padding(.horizontal, 18)
                Spacer().frame(height: 30)
                expectedResultsSection
                    .padding(.horizontal, 30)
                Spacer()
                planPicker
                    .padding(.horizontal, 18)
                Spacer().frame(height: 16)
                ctaSection
                    .padding(.horizontal, 18)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button { onNext() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.offTextMuted)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.offBackgroundSecondary))
                            .overlay(Circle().stroke(Color.offStroke, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                    .padding(.trailing, 24)
                }
                Spacer()
            }
        }
        .task {
            withAnimation(.easeOut(duration: 0.6)) {
                hasAppeared = true
            }
        }
    }
}

// MARK: - Sections
private extension PaywallView {

    var heroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Take your life back")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)

            Text("Stop auto pilot, reclaim \(daysPerYear) days a year")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(y: hasAppeared ? 0 : 12)
        .opacity(hasAppeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: hasAppeared)
    }

    var benefitSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            benefitRow(
                icon: "text.bubble.fill",
                title: "Personal Guidance",
                description: "See what's changing, why, and what to expect next"
            )
            benefitRow(
                icon: "arrow.triangle.2.circlepath",
                title: "A plan that adapts to you",
                description: "Your journey adjusts based on your real progress"
            )
            benefitRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "See your progress",
                description: "Track how you change over time"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(y: hasAppeared ? 0 : 12)
        .opacity(hasAppeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: hasAppeared)
    }

    var expectedResultsSection: some View {
        autoScrollingResults
            .padding(.horizontal, -24)
            .offset(y: hasAppeared ? 0 : 12)
            .opacity(hasAppeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.20), value: hasAppeared)
    }

    var planPicker: some View {
        ZStack {
            VStack(spacing: 18) {
                Text("✓ No commitment - Cancel Anytime")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                
                VStack(spacing: 6) {
                    VStack {
                        planCard(period: "Yearly", amount: "$39.99", unit: "/ year", plan: .yearly, isTrial: true)
                        planCard(period: "Weekly", amount: "$7.99", unit: "/ week", plan: .weekly, isTrial: false)
                    }
                }
            }

//            Text("Limited time 50% OFF")
//                .font(.system(size: 12, weight: .bold))
//                .foregroundStyle(.white)
//                .padding(.horizontal, 12)
//                .padding(.vertical, 6)
//                .background(Capsule().fill(Color.offAccent))
//                .offset(y: -50)
        }
        .offset(y: hasAppeared ? 0 : 12)
        .opacity(hasAppeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.30), value: hasAppeared)
    }

    var ctaSection: some View {
        VStack(spacing: 0) {
            Button { } label: {
                Text(selectedPlan == .yearly ? "Start My 3-Day Free Trial" : "Subscribe Now")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(LinearGradient(
                                colors: [Color.offAccent, Color.offAccent.opacity(0.85)],
                                startPoint: .top, endPoint: .bottom
                            ))
                    )
                    .foregroundStyle(.white)
            }

            HStack(spacing: 0) {
                Text("Terms & Privacy · ")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.offTextMuted)

                Button { } label: {
                    Text("Restore purchases")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .offset(y: hasAppeared ? 0 : 12)
        .opacity(hasAppeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.40), value: hasAppeared)
    }
}

// MARK: - Helper Views
private extension PaywallView {

    func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)],
                        center: .center, startRadius: 0, endRadius: 16
                    ))
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LinearGradient(
                        colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                        startPoint: .top, endPoint: .bottom
                    ))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
            }
        }
    }

    var autoScrollingResults: some View {
        let cardWidth: CGFloat = 140
        let cardSpacing: CGFloat = 10
        let totalSetWidth = CGFloat(metrics.count) * (cardWidth + cardSpacing)

        return GeometryReader { _ in
            HStack(spacing: cardSpacing) {
                ForEach(Array((metrics + metrics).enumerated()), id: \.offset) { _, metric in
                    compactResultCard(metric: metric)
                        .frame(width: cardWidth)
                }
            }
            .padding(.horizontal, 24)
            .offset(x: -scrollOffset)
        }
        .clipped()
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(0.8))
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    scrollOffset = totalSetWidth
                }
            }
        }
    }

    func compactResultCard(metric: ResultMetric) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 14))
                    .frame(width: 28, height: 28)

                Image(systemName: metric.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(metric.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)
                .lineLimit(1)

            Text(metric.description)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineLimit(2)
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [Color.offAccent.opacity(0.04), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }

    func planCard(period: String, amount: String, unit: String, plan: SubscriptionPlan, isTrial: Bool = false) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedPlan = plan
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(period.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.offTextSecondary)
                        .tracking(0.3)

                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(amount)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.offTextPrimary)

                        Text(unit)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.offTextMuted)
                    }
                }

                Spacer()

                if isTrial {
                    Text("FREE TRIAL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.offAccent)
                        .tracking(0.3)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.offAccent.opacity(0.1)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color.offAccent.opacity(0.04) : Color.offBackgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.offAccent : Color.offStroke, lineWidth: isSelected ? 1.5 : 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Result Metric
private struct ResultMetric {
    let icon: String
    let title: String
    let description: String
}

private let metrics: [ResultMetric] = [
    ResultMetric(icon: "brain.head.profile", title: "Clarity", description: "Less mental \nfog"),
    ResultMetric(icon: "scope", title: "Focus", description: "Easier to \nhold focus"),
    ResultMetric(icon: "bolt.fill", title: "Energy", description: "More steady \nenergy"),
    ResultMetric(icon: "flag.checkered", title: "Drive", description: "Less resistance \nto start"),
    ResultMetric(icon: "hand.raised.slash.fill", title: "Control", description: "More intentional \nuse"),
    ResultMetric(icon: "hourglass", title: "Patience", description: "Less urgency, \nmore calm"),
]


#Preview {
    PaywallView(
        onNext: {},
        daysPerYear: 47,
        outcomeSummary: "more clarity, sharper focus, steadier energy"
    )
}
