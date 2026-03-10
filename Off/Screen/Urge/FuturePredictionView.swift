//
//  FuturePredictionView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct FuturePredictionView: View {

    var onSelect: (PredictedFeeling) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            iconSection
            promptSection
            optionsSection
            Spacer()
        }
    }
}

// MARK: - Sections

private extension FuturePredictionView {

    var iconSection: some View {
        Image(systemName: "clock.fill")
            .font(.system(size: 48, weight: .light))
            .foregroundStyle(
                LinearGradient(
                    colors: [.offAccent.opacity(0.15), .offAccent.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    var promptSection: some View {
        VStack(spacing: 24) {
            Text("If you use social media for the next 30 minutes...")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextMuted)
                .multilineTextAlignment(.center)

            Text("How will you feel after?")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.offTextPrimary)
                .multilineTextAlignment(.center)
        }
    }

    var optionsSection: some View {
        VStack(spacing: 12) {
            optionButton(emoji: "\u{1F60A}", label: "Better") { onSelect(.better) }
            optionButton(emoji: "\u{1F610}", label: "Same") { onSelect(.same) }
            optionButton(emoji: "\u{1F614}", label: "Worse") { onSelect(.worse) }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - View Helpers

private extension FuturePredictionView {

    func optionButton(emoji: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 24))
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.offTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.offBackgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.7), .offAccent.opacity(0.03)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.offStroke.opacity(0.7), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            )
        }
    }
}

#Preview {
    FuturePredictionView { _ in }
        .withPreviewManagers()
}
