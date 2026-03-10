//
//  SocialImpactView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct SocialImpactView: View {

    @Environment(OnboardingManager.self) var manager
    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection
                        explanationSection
                        bulletsSection
                        inactionSection
                        conclusionSection
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                ctaSection
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Sections
private extension SocialImpactView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("That time adds up")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Text("At this pace, social media adds up to about **\(manager.daysPerYear) full days a year**.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    var explanationSection: some View {
        Text("When that much time goes into fast, endless content, the brain adapts to constant stimulation. Over time, it tends to:")
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.offTextSecondary)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    var bulletsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            impactBullet("Keep attention in a reactive loop.")
            impactBullet("Make focus harder to sustain — even for simple tasks.")
            impactBullet("Make mental rest feel less restorative.")
        }
    }

    var inactionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("And it doesn't stop here")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)

            Text("In **5 years**, that's **\(manager.daysPerYear * 5) days** — almost a full year spent scrolling. The fog, the restlessness, the lack of drive — they don't fix themselves. Tolerance builds, and the same content gives less back each time.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 8)
    }

    var conclusionSection: some View {
        Text("But even **30 minutes less per day** is about **\(manager.daysSavedPerYear) full days a year** with less stimulation — without quitting everything.")
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.offTextSecondary)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 4)
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
private extension SocialImpactView {

    func impactBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 16))
                    .frame(width: 28, height: 28)

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            }

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
        }
    }
}

#Preview {
    SocialImpactView(onNext: {})
        .environment(OnboardingManager())
}
