//
//  RealityCheckView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct RealityCheckView: View {

    let reason: UrgeReason
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            scrollContent
            continueButton
        }
    }
}

// MARK: - Sections

private extension RealityCheckView {

    var scrollContent: some View {
        ScrollView {
            VStack(spacing: 28) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.offAccent.opacity(0.2), .offAccent.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text(reason.realityTitle)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.offTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                Text(reason.realityBody)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.offTextSecondary)
                    .lineSpacing(6)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                ZStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(reason.realityHelpTitle)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.offAccent)

                        ForEach(reason.realityHelpItems, id: \.self) { item in
                            helpItem(text: item)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.offBackgroundSecondary)

                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.5), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )

                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.offAccent.opacity(0.04), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.offStroke, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 12)
                    .shadow(color: .offAccent.opacity(0.03), radius: 20)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.offAccent.opacity(0.3))
                        .frame(width: 3)
                        .padding(.vertical, 16)
                        .padding(.leading, 8)
                }
                .padding(.horizontal, 28)
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
    }

    var continueButton: some View {
        Button(action: onContinue) {
            Text("Continue")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.offAccent, .offAccent.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .shadow(color: .offAccent.opacity(0.25), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 28)
        .padding(.bottom, 16)
    }
}

// MARK: - View Helpers

private extension RealityCheckView {

    func helpItem(text: String) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.offAccent.opacity(0.15), .offAccent.opacity(0.05)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 14
                    )
                )
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.offAccent, .offAccent.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.offTextPrimary)
        }
    }
}

#Preview {
    RealityCheckView(reason: .distraction) { }
        .withPreviewManagers()
}
