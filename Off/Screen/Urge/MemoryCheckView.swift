//
//  MemoryCheckView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct MemoryCheckView: View {

    let reason: UrgeReason
    var onSelect: (MemoryOfSuccess) -> Void

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

private extension MemoryCheckView {

    var iconSection: some View {
        Image(systemName: "brain.head.profile")
            .font(.system(size: 48, weight: .light))
            .foregroundStyle(.offAccent.opacity(0.15))
    }

    var promptSection: some View {
        VStack(spacing: 24) {
            Text(reason.memoryQuestion)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.offTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text(reason.memorySubtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.offTextMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    var optionsSection: some View {
        VStack(spacing: 12) {
            optionButton(emoji: "\u{1F44D}", label: "Yes, I remember") { onSelect(.yesIRemember) }
            optionButton(emoji: "\u{1F914}", label: "Don't remember") { onSelect(.dontRemember) }
            optionButton(emoji: "\u{1F645}", label: "Never happened") { onSelect(.neverHappened) }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - View Helpers

private extension MemoryCheckView {

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
    MemoryCheckView(reason: .distraction) { _ in }
        .withPreviewManagers()
}
